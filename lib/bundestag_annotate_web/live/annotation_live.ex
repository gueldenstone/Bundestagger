defmodule BundestagAnnotateWeb.AnnotationLive do
  @moduledoc """
  LiveView for annotating document excerpts with categories.
  """

  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.{Documents, Categories}
  alias BundestagAnnotate.Documents.{Document, Excerpt}
  alias BundestagAnnotate.Documents.Category
  import BundestagAnnotateWeb.AnnotationComponents

  @type socket :: Phoenix.LiveView.Socket.t()
  @type params :: map()

  @impl true
  def mount(%{"id" => document_id} = params, _session, socket) do
    # Extract state parameters from URL
    state = Map.drop(params, ["id"])

    with {:ok, document} <- load_document(document_id),
         {:ok, excerpts} <- load_excerpts(document_id),
         {:ok, categories} <- load_categories() do
      {:ok, initialize_socket(socket, document, excerpts, categories, state)}
    else
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Document not found")
         |> push_patch(to: ~p"/documents?#{URI.encode_query(state)}")}

      {:error, reason} ->
        {:ok,
         socket
         |> put_flash(:error, "Failed to load data: #{inspect(reason)}")
         |> push_patch(to: ~p"/documents?#{URI.encode_query(state)}")}
    end
  end

  @spec load_document(String.t()) :: {:ok, Document.t()} | {:error, :not_found}
  defp load_document(document_id) do
    case Documents.get_document(document_id) do
      nil -> {:error, :not_found}
      document -> {:ok, document}
    end
  end

  @spec load_excerpts(String.t()) :: {:ok, [Excerpt.t()]} | {:error, term()}
  defp load_excerpts(document_id) do
    try do
      excerpts =
        Documents.list_excerpts_by_document(document_id) |> Documents.preload_categories()

      {:ok, excerpts}
    rescue
      e -> {:error, e}
    end
  end

  @spec load_categories() :: {:ok, [Category.t()]} | {:error, term()}
  defp load_categories() do
    try do
      categories = Categories.list_categories()
      {:ok, categories}
    rescue
      e -> {:error, e}
    end
  end

  @spec initialize_socket(socket(), Document.t(), [Excerpt.t()], [Category.t()], map()) ::
          socket()
  defp initialize_socket(socket, document, excerpts, categories, state) do
    excerpt_map = Map.new(excerpts, fn excerpt -> {excerpt.excerpt_id, excerpt} end)
    document = Map.put(document, :excerpts, excerpts)

    socket
    |> assign(:document, document)
    |> assign(:excerpts, excerpts)
    |> assign(:categories, categories)
    |> assign(:open_dropdowns, %{})
    |> assign(:show_new_category_modal, false)
    |> assign(:new_category, %{name: "", description: "", color: "#3B82F6"})
    |> assign(:all_categorized, all_excerpts_categorized?(excerpts))
    |> assign(:excerpt_map, excerpt_map)
    |> assign(:state, state)
  end

  @spec all_excerpts_categorized?([Excerpt.t()]) :: boolean()
  defp all_excerpts_categorized?(excerpts) do
    Enum.all?(excerpts, & &1.category)
  end

  @spec toggle_dropdown_state(map(), String.t()) :: map()
  defp toggle_dropdown_state(dropdowns, excerpt_id) do
    if dropdowns[excerpt_id] do
      Map.delete(dropdowns, excerpt_id)
    else
      Map.put(dropdowns, excerpt_id, true)
    end
  end

  @spec get_excerpt(String.t()) :: {:ok, Excerpt.t()} | {:error, :not_found}
  defp get_excerpt(excerpt_id) do
    case Documents.get_excerpt(excerpt_id) do
      nil -> {:error, :not_found}
      excerpt -> {:ok, excerpt}
    end
  end

  @spec get_category(String.t()) :: {:ok, Category.t()} | {:error, :not_found}
  defp get_category(category_id) do
    case Categories.get_category(category_id) do
      nil -> {:error, :not_found}
      category -> {:ok, category}
    end
  end

  @spec update_excerpt_category(Excerpt.t(), Category.t()) ::
          {:ok, Excerpt.t()} | {:error, Ecto.Changeset.t()}
  defp update_excerpt_category(excerpt, category) do
    Documents.update_excerpt(excerpt, %{category_id: category.category_id})
  end

  @spec update_excerpts_list([Excerpt.t()], String.t(), Excerpt.t()) :: [Excerpt.t()]
  defp update_excerpts_list(excerpts, excerpt_id, updated_excerpt) do
    Enum.map(excerpts, fn e ->
      if e.excerpt_id == excerpt_id, do: updated_excerpt, else: e
    end)
  end

  @spec format_changeset_errors(Ecto.Changeset.t()) :: String.t()
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join(", ", fn {_field, errors} -> errors end)
  end

  # Group all handle_event/3 functions together
  @impl true
  def handle_event("toggle_dropdown", %{"excerpt-id" => excerpt_id}, socket) do
    current_dropdowns = socket.assigns.open_dropdowns
    new_dropdowns = toggle_dropdown_state(current_dropdowns, excerpt_id)
    {:noreply, assign(socket, :open_dropdowns, new_dropdowns)}
  end

  @impl true
  def handle_event("show_new_category_modal", %{"excerpt-id" => excerpt_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_new_category_modal, true)
     |> assign(:open_dropdowns, Map.delete(socket.assigns.open_dropdowns, excerpt_id))}
  end

  @impl true
  def handle_event("hide_new_category_modal", _params, socket) do
    {:noreply, assign(socket, :show_new_category_modal, false)}
  end

  @impl true
  def handle_event("update_new_category", %{"field" => field, "value" => value}, socket) do
    new_category = Map.put(socket.assigns.new_category, String.to_atom(field), value)
    {:noreply, assign(socket, :new_category, new_category)}
  end

  @impl true
  def handle_event("create_category", _params, socket) do
    case Categories.create_category(socket.assigns.new_category) do
      {:ok, category} ->
        {:noreply,
         socket
         |> assign(:categories, [category | socket.assigns.categories])
         |> assign(:show_new_category_modal, false)
         |> assign(:new_category, %{name: "", description: "", color: "#3B82F6"})
         |> put_flash(:info, "Category created successfully")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to create category: #{format_changeset_errors(changeset)}")}
    end
  end

  @impl true
  def handle_event(
        "select_category",
        %{"excerpt-id" => excerpt_id, "category-id" => category_id},
        socket
      ) do
    with {:ok, excerpt} <- get_excerpt(excerpt_id),
         {:ok, category} <- get_category(category_id),
         {:ok, updated_excerpt} <- update_excerpt_category(excerpt, category) do
      updated_excerpt = Documents.preload_categories(updated_excerpt)
      excerpts = update_excerpts_list(socket.assigns.excerpts, excerpt_id, updated_excerpt)

      {:noreply,
       socket
       |> assign(:excerpts, excerpts)
       |> assign(:open_dropdowns, Map.delete(socket.assigns.open_dropdowns, excerpt_id))
       |> assign(:all_categorized, all_excerpts_categorized?(excerpts))
       |> put_flash(:info, "Category selected successfully")}
    else
      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to find excerpt or category")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update excerpt: #{format_changeset_errors(changeset)}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <.back_button state={@state} />
      <.document_title document={@document} all_categorized={@all_categorized} />
      <.excerpts_list excerpts={@excerpts} categories={@categories} open_dropdowns={@open_dropdowns} />
      <.new_category_modal show={@show_new_category_modal} category={@new_category} />
    </div>
    """
  end
end

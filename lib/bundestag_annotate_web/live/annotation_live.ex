defmodule BundestagAnnotateWeb.AnnotationLive do
  @moduledoc """
  LiveView for annotating document excerpts with categories.
  """

  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.{Documents, Categories}
  import BundestagAnnotateWeb.AnnotationComponents

  @impl true
  def mount(%{"id" => document_id}, _session, socket) do
    case Documents.get_document(document_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Document not found")
         |> redirect(to: ~p"/documents")}

      document ->
        excerpts =
          Documents.list_excerpts_by_document(document_id) |> Documents.preload_categories()

        categories = Categories.list_categories()

        # Create a map of excerpt IDs to their content for quick lookup
        excerpt_map = Map.new(excerpts, fn excerpt -> {excerpt.excerpt_id, excerpt} end)

        # Preload excerpts into the document
        document = Map.put(document, :excerpts, excerpts)

        {:ok,
         socket
         |> assign(:document, document)
         |> assign(:excerpts, excerpts)
         |> assign(:categories, categories)
         |> assign(:open_dropdowns, %{})
         |> assign(:show_new_category_modal, false)
         |> assign(:new_category, %{name: "", description: "", color: "#3B82F6"})
         |> assign(:all_categorized, all_excerpts_categorized?(excerpts))
         |> assign(:document_content_expanded, false)
         |> assign(:excerpt_map, excerpt_map)}
    end
  end

  defp all_excerpts_categorized?(excerpts) do
    Enum.all?(excerpts, & &1.category)
  end

  @impl true
  def handle_event("toggle_dropdown", %{"excerpt-id" => excerpt_id}, socket) do
    current_dropdowns = socket.assigns.open_dropdowns

    new_dropdowns =
      if current_dropdowns[excerpt_id] do
        Map.delete(current_dropdowns, excerpt_id)
      else
        Map.put(current_dropdowns, excerpt_id, true)
      end

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
         |> assign(:new_category, %{name: "", description: "", color: "#3B82F6"})}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "select_category",
        %{"excerpt-id" => excerpt_id, "category-id" => category_id},
        socket
      ) do
    excerpt = Documents.get_excerpt!(excerpt_id)
    category = Categories.get_category!(category_id)

    case Documents.update_excerpt(excerpt, %{category_id: category.category_id}) do
      {:ok, updated_excerpt} ->
        updated_excerpt = Documents.preload_categories(updated_excerpt)

        excerpts =
          Enum.map(socket.assigns.excerpts, fn e ->
            if e.excerpt_id == excerpt_id, do: updated_excerpt, else: e
          end)

        {:noreply,
         socket
         |> assign(:excerpts, excerpts)
         |> assign(:open_dropdowns, Map.delete(socket.assigns.open_dropdowns, excerpt_id))
         |> assign(:all_categorized, all_excerpts_categorized?(excerpts))}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_document_content", _params, socket) do
    {:noreply,
     assign(socket, :document_content_expanded, !socket.assigns.document_content_expanded)}
  end

  @impl true
  def handle_event("jump_to_text", %{"excerpt-id" => excerpt_id}, socket) do
    excerpt = socket.assigns.excerpt_map[excerpt_id]

    # First ensure the document content is expanded
    socket = assign(socket, :document_content_expanded, true)

    # Push a JavaScript event to handle the scrolling
    {:noreply,
     socket
     |> push_event("js-exec", %{
       to: "#document-content",
       attr: "data-excerpt-id",
       val: excerpt_id,
       content: excerpt.sentence_with_keyword
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <.back_button />
      <.document_title document={@document} all_categorized={@all_categorized} />
      <.excerpts_list excerpts={@excerpts} categories={@categories} open_dropdowns={@open_dropdowns} />
      <.document_content content={@document.content} is_expanded={@document_content_expanded} />
      <.new_category_modal show={@show_new_category_modal} category={@new_category} />
    </div>
    """
  end
end

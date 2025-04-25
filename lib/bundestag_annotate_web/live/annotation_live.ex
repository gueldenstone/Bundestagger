defmodule BundestagAnnotateWeb.AnnotationLive do
  @moduledoc """
  LiveView for annotating document excerpts with categories.
  """

  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.{Documents, Categories}

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

        {:ok,
         socket
         |> assign(:document, document)
         |> assign(:excerpts, excerpts)
         |> assign(:categories, categories)
         |> assign(:open_dropdowns, %{})
         |> assign(:show_new_category_modal, false)
         |> assign(:new_category, %{name: "", description: "", color: "#3B82F6"})}
    end
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
         |> assign(:open_dropdowns, Map.delete(socket.assigns.open_dropdowns, excerpt_id))}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <.back_button />
      <.document_title document={@document} />
      <.excerpts_list excerpts={@excerpts} categories={@categories} open_dropdowns={@open_dropdowns} />
      <.new_category_modal show={@show_new_category_modal} category={@new_category} />
    </div>
    """
  end

  defp back_button(assigns) do
    ~H"""
    <div class="mb-6">
      <.link
        navigate={~p"/documents"}
        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5 mr-2"
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z"
            clip-rule="evenodd"
          />
        </svg>
        Back to documents
      </.link>
    </div>
    """
  end

  defp document_title(assigns) do
    ~H"""
    <h1 class="text-3xl font-bold mb-8">{@document.title}</h1>
    """
  end

  defp excerpts_list(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= for excerpt <- @excerpts do %>
        <.excerpt_card
          excerpt={excerpt}
          categories={@categories}
          is_dropdown_open={@open_dropdowns[excerpt.excerpt_id]}
        />
      <% end %>
    </div>
    """
  end

  defp excerpt_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex-1">
        <.excerpt_content excerpt={@excerpt} />
        <.excerpt_category excerpt={@excerpt} />
      </div>
      <div class="mt-4">
        <.category_dropdown excerpt={@excerpt} categories={@categories} is_open={@is_dropdown_open} />
      </div>
    </div>
    """
  end

  defp excerpt_content(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= if @excerpt.sentence_before do %>
        <p class="text-gray-600">{@excerpt.sentence_before}</p>
      <% end %>
      <p class="text-gray-800 font-medium">{@excerpt.sentence_with_keyword}</p>
      <%= if @excerpt.sentence_after do %>
        <p class="text-gray-600">{@excerpt.sentence_after}</p>
      <% end %>
    </div>
    """
  end

  defp excerpt_category(assigns) do
    ~H"""
    <div class="flex items-center space-x-2 mt-4">
      <%= if @excerpt.category do %>
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
          {@excerpt.category.name}
        </span>
      <% else %>
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
          No category
        </span>
      <% end %>
    </div>
    """
  end

  defp category_dropdown(assigns) do
    ~H"""
    <div class="relative">
      <button
        phx-click="toggle_dropdown"
        phx-value-excerpt-id={@excerpt.excerpt_id}
        class="w-full inline-flex items-center justify-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Select Category
      </button>
      <div
        class={"#{if @is_open, do: "block", else: "hidden"} absolute left-0 right-0 mt-2 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-10"}
        phx-click-away="toggle_dropdown"
        phx-value-excerpt-id={@excerpt.excerpt_id}
      >
        <div class="py-1" role="menu" aria-orientation="vertical">
          <%= for category <- @categories do %>
            <form phx-submit="select_category" class="w-full">
              <input type="hidden" name="excerpt-id" value={@excerpt.excerpt_id} />
              <input type="hidden" name="category-id" value={category.category_id} />
              <button
                type="submit"
                class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                role="menuitem"
              >
                <div class="flex items-center gap-2">
                  <span class="w-3 h-3 rounded-full" style={"background-color: #{category.color}"}>
                  </span>
                  <div class="flex-1">
                    <div class="font-medium">{category.name}</div>
                    <div class="text-zinc-500 text-sm mt-1">{category.description}</div>
                  </div>
                </div>
              </button>
            </form>
          <% end %>
          <div class="border-t border-gray-100 my-1"></div>
          <button
            phx-click="show_new_category_modal"
            phx-value-excerpt-id={@excerpt.excerpt_id}
            class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
          >
            <div class="flex items-center gap-2">
              <span class="w-3 h-3 rounded-full flex items-center justify-center bg-gray-200">
                <span class="text-gray-500 text-xs">+</span>
              </span>
              <div class="font-medium">Add New Category</div>
            </div>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp new_category_modal(assigns) do
    ~H"""
    <div
      :if={@show}
      class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      aria-hidden="true"
    >
      <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div class="absolute right-0 top-0 hidden pr-4 pt-4 sm:block">
              <button
                type="button"
                class="rounded-md bg-white text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                phx-click="hide_new_category_modal"
              >
                <span class="sr-only">Close</span>
                <.icon name="hero-x-mark" class="h-6 w-6" />
              </button>
            </div>
            <div class="sm:flex sm:items-start">
              <div class="mt-3 text-center sm:mt-0 sm:text-left w-full">
                <h3 class="text-base font-semibold leading-6 text-gray-900" id="modal-title">
                  Add New Category
                </h3>
                <div class="mt-4 space-y-4">
                  <div>
                    <label for="category-name" class="block text-sm font-medium text-gray-700">
                      Name
                    </label>
                    <input
                      type="text"
                      id="category-name"
                      name="category-name"
                      value={@category.name}
                      phx-blur="update_new_category"
                      phx-value-field="name"
                      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>
                  <div>
                    <label for="category-description" class="block text-sm font-medium text-gray-700">
                      Description
                    </label>
                    <textarea
                      id="category-description"
                      name="category-description"
                      rows="3"
                      value={@category.description}
                      phx-blur="update_new_category"
                      phx-value-field="description"
                      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    ></textarea>
                  </div>
                  <div>
                    <label for="category-color" class="block text-sm font-medium text-gray-700">
                      Color
                    </label>
                    <input
                      type="color"
                      id="category-color"
                      name="category-color"
                      value={@category.color}
                      phx-change="update_new_category"
                      phx-value-field="color"
                      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
              <button
                type="button"
                class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:ml-3 sm:w-auto"
                phx-click="create_category"
              >
                Create
              </button>
              <button
                type="button"
                class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
                phx-click="hide_new_category_modal"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

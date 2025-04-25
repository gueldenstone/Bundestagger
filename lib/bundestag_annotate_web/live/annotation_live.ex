defmodule BundestagAnnotateWeb.AnnotationLive do
  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.Documents

  def mount(%{"id" => document_id}, _session, socket) do
    document = Documents.get_document!(document_id)
    excerpts = Documents.list_excerpts_by_document(document_id) |> Documents.preload_categories()
    categories = Documents.list_categories()

    {:ok,
     socket
     |> assign(:document, document)
     |> assign(:excerpts, excerpts)
     |> assign(:categories, categories)
     |> assign(:open_dropdowns, %{})}
  end

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

  def handle_event(
        "select_category",
        %{"excerpt-id" => excerpt_id, "category-id" => category_id},
        socket
      ) do
    excerpt = Documents.get_excerpt!(excerpt_id)
    category = Documents.get_category!(category_id)

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

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
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

      <h1 class="text-3xl font-bold mb-8">{@document.title}</h1>

      <div class="space-y-6">
        <%= for excerpt <- @excerpts do %>
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="space-y-2">
                  <%= if excerpt.sentence_before do %>
                    <p class="text-gray-600">{excerpt.sentence_before}</p>
                  <% end %>
                  <p class="text-gray-800 font-medium">{excerpt.sentence_with_keyword}</p>
                  <%= if excerpt.sentence_after do %>
                    <p class="text-gray-600">{excerpt.sentence_after}</p>
                  <% end %>
                </div>
                <div class="flex items-center space-x-2 mt-4">
                  <%= if excerpt.category do %>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {excerpt.category.name}
                    </span>
                  <% else %>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                      No category
                    </span>
                  <% end %>
                </div>
              </div>
              <div class="relative">
                <button
                  phx-click="toggle_dropdown"
                  phx-value-excerpt-id={excerpt.excerpt_id}
                  class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Select Category
                </button>
                <div
                  class={"#{if @open_dropdowns[excerpt.excerpt_id], do: "block", else: "hidden"} absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-10"}
                  phx-click-away="toggle_dropdown"
                  phx-value-excerpt-id={excerpt.excerpt_id}
                >
                  <div class="py-1" role="menu" aria-orientation="vertical">
                    <%= for category <- @categories do %>
                      <button
                        phx-click="select_category"
                        phx-value-excerpt-id={excerpt.excerpt_id}
                        phx-value-category-id={category.category_id}
                        class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                        role="menuitem"
                      >
                        {category.name}
                      </button>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end

defmodule BundestagAnnotateWeb.AnnotationComponents do
  @moduledoc """
  Provides components for the annotation interface.
  """
  use BundestagAnnotateWeb, :html
  import BundestagAnnotateWeb.CoreComponents

  def back_button(assigns) do
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

  def document_title(assigns) do
    ~H"""
    <div class="flex items-center gap-4 mb-8">
      <h1 class="text-3xl font-bold">{@document.title}</h1>
      <%= if @all_categorized do %>
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 mr-1"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clip-rule="evenodd"
            />
          </svg>
          All categorized
        </span>
      <% else %>
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 mr-1"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
              clip-rule="evenodd"
            />
          </svg>
          Needs categorization
        </span>
      <% end %>
    </div>
    """
  end

  def excerpts_list(assigns) do
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

  def excerpt_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex items-start justify-between">
        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
          {@excerpt.keyword}
        </span>
        <.excerpt_category excerpt={@excerpt} />
      </div>
      <div class="mt-4">
        <.excerpt_content excerpt={@excerpt} />
      </div>
      <div class="mt-4 flex gap-2">
        <div class="flex-1">
          <.category_dropdown excerpt={@excerpt} categories={@categories} is_open={@is_dropdown_open} />
        </div>
        <button
          phx-click="jump_to_text"
          phx-value-excerpt-id={@excerpt.excerpt_id}
          class="inline-flex items-center justify-center p-2 text-gray-500 hover:text-gray-700 focus:outline-none"
          title="Jump to Text"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-8.707l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L9 9.414V13a1 1 0 102 0V9.414l1.293 1.293a1 1 0 001.414-1.414z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      </div>
    </div>
    """
  end

  def excerpt_content(assigns) do
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

  def excerpt_category(assigns) do
    ~H"""
    <%= if @excerpt.category do %>
      <span
        class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
        style={"background-color: #{@excerpt.category.color}; color: white;"}
      >
        {@excerpt.category.name}
      </span>
    <% else %>
      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
        No category
      </span>
    <% end %>
    """
  end

  def category_dropdown(assigns) do
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

  def new_category_modal(assigns) do
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
                      phx-value-description={@category.description}
                      phx-blur="update_new_category"
                      phx-value-field="description"
                      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    >{@category.description}</textarea>
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

  def document_content(assigns) do
    ~H"""
    <div class="mt-8">
      <button
        phx-click="toggle_document_content"
        class="w-full flex items-center justify-between px-4 py-2 bg-white border border-gray-200 rounded-lg hover:bg-gray-50"
      >
        <span class="font-medium text-gray-900">View Full Document Content</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 text-gray-500 transform transition-transform #{if @is_expanded, do: "rotate-180", else: ""}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <div class={"mt-4 bg-white rounded-lg shadow p-6 #{if @is_expanded, do: "block", else: "hidden"}"}>
        <div class="prose max-w-none" id="document-content">
          <%= for {paragraph, index} <- Enum.with_index(String.split(@content, "\n")) do %>
            <p id={"paragraph-#{index}"} class="mb-4">{paragraph}</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end

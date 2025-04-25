defmodule BundestagAnnotateWeb.DocumentsLive do
  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("=== Handle Params ===")
    IO.puts("Params: #{inspect(params)}")

    # Parse the query string if it exists
    parsed_params =
      case params do
        %{"" => query_string} when is_binary(query_string) ->
          URI.decode_query(query_string)

        _ ->
          params
      end

    IO.puts("Parsed params: #{inspect(parsed_params)}")

    # Extract individual parameters from the query string
    page = String.to_integer(parsed_params["page"] || "1")
    per_page = String.to_integer(parsed_params["per_page"] || "10")
    sort_order = parsed_params["sort_order"] || socket.assigns[:sort_order] || "desc"
    has_excerpts = parsed_params["has_excerpts"] || "true"

    IO.puts("New sort_order: #{sort_order}")

    socket =
      socket
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:sort_order, sort_order)
      |> assign(:has_excerpts, has_excerpts)

    {:noreply, assign_documents(socket)}
  end

  defp assign_documents(socket) do
    %{
      page: page,
      per_page: per_page,
      sort_order: sort_order,
      has_excerpts: has_excerpts
    } = socket.assigns

    IO.puts("assign_documents - sort_order: #{sort_order}")

    {documents, total_count} =
      Documents.list_documents(
        page: page,
        per_page: per_page,
        sort_order: sort_order,
        has_excerpts: has_excerpts == "true"
      )

    assign(socket,
      documents: documents,
      total_count: total_count
    )
  end

  @impl true
  def handle_event("update_sort", %{"value" => new_sort_order}, socket) do
    IO.puts("=== Update Sort Event ===")
    IO.puts("Params: #{inspect(%{"value" => new_sort_order})}")
    IO.puts("Current sort_order: #{socket.assigns.sort_order}")
    IO.puts("New sort_order: #{new_sort_order}")

    # Update the socket assigns first
    socket = assign(socket, :sort_order, new_sort_order)

    # Then update the documents with the new sort order
    socket = assign_documents(socket)

    # Finally, push the patch to update the URL
    {:noreply,
     push_patch(socket,
       to:
         ~p"/documents?#{build_query_params(socket.assigns.page, socket.assigns.per_page, new_sort_order, socket.assigns.has_excerpts)}"
     )}
  end

  @impl true
  def handle_event("update_filter", %{"has_excerpts" => has_excerpts}, socket) do
    {:noreply,
     socket
     |> assign(:has_excerpts, has_excerpts)
     |> assign(:page, 1)
     |> assign_documents()}
  end

  @impl true
  def handle_event("update_per_page", %{"per_page" => per_page}, socket) do
    {:noreply,
     socket
     |> assign(:per_page, String.to_integer(per_page))
     |> assign(:page, 1)
     |> assign_documents()}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)

    {:noreply,
     push_patch(socket,
       to:
         ~p"/documents?#{build_query_params(page, socket.assigns.per_page, socket.assigns.sort_order, socket.assigns.has_excerpts)}"
     )}
  end

  defp build_query_params(page, per_page, sort_order, has_excerpts) do
    %{
      "page" => page,
      "per_page" => per_page,
      "sort_order" => sort_order,
      "has_excerpts" => has_excerpts
    }
    |> URI.encode_query()
  end
end

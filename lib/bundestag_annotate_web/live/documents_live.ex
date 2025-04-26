defmodule BundestagAnnotateWeb.DocumentsLive do
  use BundestagAnnotateWeb, :live_view
  alias BundestagAnnotate.Documents

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page, 1)
      |> assign(:per_page, 10)
      |> assign(:sort_order, "desc")
      |> assign(:has_excerpts, "true")
      |> assign(:documents, [])
      |> assign(:total_count, 0)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # Parse the query string if it comes as a key
    parsed_params =
      case Map.keys(params) do
        [key] when is_binary(key) ->
          if String.contains?(key, "=") do
            URI.decode_query(key)
          else
            # If it's a single key without =, treat it as a parameter name with empty value
            %{key => ""}
          end

        _ ->
          params
      end

    # Extract individual parameters from the query string with defaults
    page = parse_integer_param(parsed_params["page"], 1)
    per_page = parse_integer_param(parsed_params["per_page"], 10)
    sort_order = parsed_params["sort_order"] || "desc"
    has_excerpts = parsed_params["has_excerpts"] || "true"

    # Update socket assigns
    socket =
      socket
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:sort_order, sort_order)
      |> assign(:has_excerpts, has_excerpts)
      |> assign_documents()

    {:noreply, socket}
  end

  defp parse_integer_param(nil, default), do: default
  defp parse_integer_param(value, _default) when is_integer(value), do: value

  defp parse_integer_param(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp assign_documents(socket) do
    %{
      page: page,
      per_page: per_page,
      sort_order: sort_order,
      has_excerpts: has_excerpts
    } = socket.assigns

    case Documents.list_documents(
           page: page,
           per_page: per_page,
           sort_order: sort_order,
           has_excerpts: has_excerpts == "true"
         ) do
      {documents, total_count} ->
        assign(socket,
          documents: documents,
          total_count: total_count
        )

      _ ->
        socket
        |> put_flash(:error, "Failed to load documents")
        |> assign(documents: [], total_count: 0)
    end
  end

  @impl true
  def handle_event("update_sort", %{"value" => new_sort_order}, socket) do
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
  def handle_event("update_filter", %{"value" => has_excerpts}, socket) do
    socket =
      socket
      |> assign(:has_excerpts, has_excerpts)
      |> assign(:page, 1)
      |> assign_documents()

    {:noreply,
     push_patch(socket,
       to:
         ~p"/documents?#{build_query_params(1, socket.assigns.per_page, socket.assigns.sort_order, has_excerpts)}"
     )}
  end

  @impl true
  def handle_event("update_per_page", %{"value" => per_page}, socket) do
    case Integer.parse(per_page) do
      {int, _} ->
        # Update the socket assigns first
        socket = assign(socket, :per_page, int)
        socket = assign(socket, :page, 1)

        # Then update the documents with the new per_page
        socket = assign_documents(socket)

        # Finally, push the patch to update the URL
        {:noreply,
         push_patch(socket,
           to:
             ~p"/documents?#{build_query_params(1, int, socket.assigns.sort_order, socket.assigns.has_excerpts)}"
         )}

      :error ->
        {:noreply, put_flash(socket, :error, "Invalid items per page value")}
    end
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    case Integer.parse(page) do
      {int, _} ->
        # Update the socket assigns first
        socket = assign(socket, :page, int)

        # Then update the documents with the new page
        socket = assign_documents(socket)

        # Finally, push the patch to update the URL
        {:noreply,
         push_patch(socket,
           to:
             ~p"/documents?#{build_query_params(int, socket.assigns.per_page, socket.assigns.sort_order, socket.assigns.has_excerpts)}"
         )}

      :error ->
        {:noreply, put_flash(socket, :error, "Invalid page number")}
    end
  end

  defp build_query_params(page, per_page, sort_order, has_excerpts) do
    params = %{
      "page" => to_string(page),
      "per_page" => to_string(per_page),
      "sort_order" => sort_order,
      "has_excerpts" => has_excerpts
    }

    # Remove any empty values and encode the query
    params
    |> Enum.reject(fn {_, v} -> v == "" end)
    |> Map.new()
    |> URI.encode_query()
  end
end

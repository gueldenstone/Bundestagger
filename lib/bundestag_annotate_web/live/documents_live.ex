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
      |> assign(:has_excerpts, true)
      |> assign(:document_type, "all")
      |> assign(:publisher, "all")
      |> assign(:loading, true)
      |> assign(:document_types, [])
      |> assign(:publishers, [])
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

    has_excerpts =
      if parsed_params["has_excerpts"] do
        parsed_params["has_excerpts"] == "true"
      else
        true
      end

    document_type = parsed_params["document_type"] || "all"
    publisher = parsed_params["publisher"] || "all"

    # Update socket assigns
    socket =
      socket
      |> assign(:page, page)
      |> assign(:per_page, per_page)
      |> assign(:sort_order, sort_order)
      |> assign(:has_excerpts, has_excerpts)
      |> assign(:document_type, document_type)
      |> assign(:publisher, publisher)
      |> assign(:loading, true)
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
      has_excerpts: has_excerpts,
      document_type: document_type,
      publisher: publisher
    } = socket.assigns

    # First, load document types and publishers
    socket =
      socket
      |> assign(:document_types, Documents.get_document_types())
      |> assign(:publishers, Documents.get_publishers())

    # Then load documents
    case {document_type, publisher} do
      {"all", "all"} ->
        case Documents.list_documents(
               page: page,
               per_page: per_page,
               sort_order: sort_order,
               has_excerpts: has_excerpts
             ) do
          {documents, total_count} ->
            assign(socket,
              documents: documents,
              total_count: total_count,
              loading: false
            )

          _ ->
            socket
            |> put_flash(:error, "Failed to load documents")
            |> assign(documents: [], total_count: 0, loading: false)
        end

      {type, "all"} ->
        case Documents.list_documents_by_type(
               type,
               page: page,
               per_page: per_page,
               sort_order: sort_order,
               has_excerpts: has_excerpts
             ) do
          {documents, total_count} ->
            assign(socket,
              documents: documents,
              total_count: total_count,
              loading: false
            )

          _ ->
            socket
            |> put_flash(:error, "Failed to load documents")
            |> assign(documents: [], total_count: 0, loading: false)
        end

      {"all", pub} ->
        case Documents.list_documents_by_publisher(
               pub,
               page: page,
               per_page: per_page,
               sort_order: sort_order,
               has_excerpts: has_excerpts
             ) do
          {documents, total_count} ->
            assign(socket,
              documents: documents,
              total_count: total_count,
              loading: false
            )

          _ ->
            socket
            |> put_flash(:error, "Failed to load documents")
            |> assign(documents: [], total_count: 0, loading: false)
        end

      {type, pub} ->
        case Documents.list_documents_by_publisher(
               pub,
               page: page,
               per_page: per_page,
               sort_order: sort_order,
               has_excerpts: has_excerpts,
               document_type: type
             ) do
          {documents, total_count} ->
            assign(socket,
              documents: documents,
              total_count: total_count,
              loading: false
            )

          _ ->
            socket
            |> put_flash(:error, "Failed to load documents")
            |> assign(documents: [], total_count: 0, loading: false)
        end
    end
  end

  @impl true
  def handle_event("update_sort_order", %{"value" => new_sort_order}, socket) do
    socket =
      socket
      |> assign(:sort_order, new_sort_order)
      |> assign(:page, 1)
      |> assign(:loading, true)
      |> assign(:documents, [])

    Process.send_after(self(), :load_documents, 0)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_has_excerpts", %{"value" => has_excerpts}, socket) do
    socket =
      socket
      |> assign(:has_excerpts, has_excerpts == "true")
      |> assign(:page, 1)
      |> assign(:loading, true)
      |> assign(:documents, [])

    Process.send_after(self(), :load_documents, 0)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_document_type", %{"value" => document_type}, socket) do
    socket =
      socket
      |> assign(:document_type, document_type)
      |> assign(:page, 1)
      |> assign(:loading, true)
      |> assign(:documents, [])

    Process.send_after(self(), :load_documents, 0)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_publisher", %{"value" => publisher}, socket) do
    socket =
      socket
      |> assign(:publisher, publisher)
      |> assign(:page, 1)
      |> assign(:loading, true)
      |> assign(:documents, [])

    Process.send_after(self(), :load_documents, 0)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_per_page", %{"value" => per_page}, socket) do
    case Integer.parse(per_page) do
      {int, _} ->
        socket =
          socket
          |> assign(:per_page, int)
          |> assign(:page, 1)
          |> assign(:loading, true)
          |> assign(:documents, [])

        Process.send_after(self(), :load_documents, 0)

        {:noreply, socket}

      :error ->
        {:noreply, put_flash(socket, :error, "Invalid items per page value")}
    end
  end

  @impl true
  def handle_event("update_page", %{"page" => page}, socket) do
    case Integer.parse(page) do
      {int, _} ->
        socket =
          socket
          |> assign(:page, int)
          |> assign(:loading, true)
          |> assign(:documents, [])

        Process.send_after(self(), :load_documents, 0)

        {:noreply, socket}

      :error ->
        {:noreply, put_flash(socket, :error, "Invalid page number")}
    end
  end

  @impl true
  def handle_info(:load_documents, socket) do
    socket = assign_documents(socket)
    {:noreply, socket}
  end

  defp build_query_params(page, per_page, sort_order, has_excerpts, document_type, publisher) do
    params = %{
      "page" => to_string(page),
      "per_page" => to_string(per_page),
      "sort_order" => sort_order,
      "has_excerpts" => to_string(has_excerpts),
      "document_type" => document_type,
      "publisher" => publisher
    }

    # Remove any empty values and encode the query
    params
    |> Enum.reject(fn {_, v} -> v == "" end)
    |> Map.new()
    |> URI.encode_query()
  end
end

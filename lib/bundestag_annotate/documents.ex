defmodule BundestagAnnotate.Documents do
  @moduledoc """
  The Documents context provides functions for managing documents and their excerpts.
  """

  use BundestagAnnotate.BaseContext
  alias BundestagAnnotate.Documents.{Document, Excerpt}
  import Ecto.Query
  alias BundestagAnnotate.Repo

  # Cache key for the current page
  @cache_key "documents_page"
  # Cache TTL in milliseconds (5 minutes)
  @cache_ttl :timer.minutes(5)
  # Cache TTL for document types and publishers (1 hour)
  @metadata_cache_ttl :timer.hours(1)

  # Document functions
  @doc """
  Returns a list of documents. When options are provided, returns a tuple with pagination info.
  """
  @spec list_documents() :: [Document.t()]
  @spec list_documents(keyword() | map()) :: [Document.t()] | {[Document.t()], integer()}
  def list_documents(opts \\ []) do
    if opts == [] do
      Repo.all(Document)
      |> Repo.preload(:excerpts)
    else
      page = Keyword.get(opts, :page, 1)
      per_page = Keyword.get(opts, :per_page, 10)
      sort_order = Keyword.get(opts, :sort_order, "desc")
      has_excerpts = Keyword.get(opts, :has_excerpts, true)
      document_type = Keyword.get(opts, :document_type, "all")
      publisher = Keyword.get(opts, :publisher, "all")
      offset = (page - 1) * per_page

      # Try to get from cache first
      cache_key =
        "#{@cache_key}_#{page}_#{per_page}_#{sort_order}_#{has_excerpts}_#{document_type}_#{publisher}"

      case Cachex.get(:documents_cache, cache_key) do
        {:ok, nil} ->
          # Cache miss, fetch from database
          fetch_and_cache_documents(
            per_page,
            sort_order,
            has_excerpts,
            document_type,
            publisher,
            offset,
            cache_key
          )

        {:ok, result} ->
          # Cache hit
          result

        _ ->
          # Cache error, fetch from database
          fetch_and_cache_documents(
            per_page,
            sort_order,
            has_excerpts,
            document_type,
            publisher,
            offset,
            cache_key
          )
      end
    end
  end

  defp fetch_and_cache_documents(
         per_page,
         sort_order,
         has_excerpts,
         document_type,
         publisher,
         offset,
         cache_key
       ) do
    # Build base query with all filters
    base_query = build_base_query(document_type, publisher)

    # Apply sorting
    base_query = apply_sorting(base_query, sort_order)

    # Get total count
    total_count = get_total_count(base_query, has_excerpts)

    # Get paginated documents
    documents = get_paginated_documents(base_query, has_excerpts, per_page, offset)

    result = {documents, total_count}

    # Cache the result with TTL
    Cachex.put(:documents_cache, cache_key, result, ttl: @cache_ttl)

    result
  end

  defp build_base_query(document_type, publisher) do
    from d in Document,
      left_join: e in assoc(d, :excerpts),
      where: ^build_where_clause(document_type, publisher)
  end

  defp build_where_clause(document_type, publisher) do
    dynamic([d], true)
    |> maybe_filter_document_type(document_type)
    |> maybe_filter_publisher(publisher)
  end

  defp maybe_filter_document_type(dynamic, "all"), do: dynamic

  defp maybe_filter_document_type(dynamic, document_type) do
    dynamic([d], ^dynamic and d.document_type == ^document_type)
  end

  defp maybe_filter_publisher(dynamic, "all"), do: dynamic

  defp maybe_filter_publisher(dynamic, publisher) do
    dynamic([d], ^dynamic and d.publisher == ^publisher)
  end

  defp apply_sorting(query, sort_order) do
    case sort_order do
      "asc" ->
        from [d, _] in query, order_by: [asc: d.date]

      "categorized" ->
        from [d, e] in query,
          group_by: d.document_id,
          order_by: [desc: count(e.category_id)]

      "uncategorized" ->
        from [d, e] in query,
          group_by: d.document_id,
          order_by: [asc: count(e.category_id)]

      _ ->
        from [d, _] in query, order_by: [desc: d.date]
    end
  end

  defp get_total_count(query, has_excerpts) do
    # Get all unique document IDs that match our filters
    document_ids_query =
      if has_excerpts do
        from [d, e] in query,
          where: not is_nil(e.excerpt_id),
          select: d.document_id
      else
        from [d, _] in query,
          select: d.document_id
      end

    # Count unique document IDs
    document_ids_query
    |> Repo.all()
    |> Enum.uniq()
    |> length()
  end

  defp get_paginated_documents(query, has_excerpts, per_page, offset) do
    # First get all unique document IDs that match our filters
    document_ids_query =
      if has_excerpts do
        from [d, e] in query,
          where: not is_nil(e.excerpt_id),
          select: d.document_id
      else
        from [d, _] in query,
          select: d.document_id
      end

    # Get all matching document IDs and apply pagination
    all_document_ids =
      document_ids_query
      |> Repo.all()
      |> Enum.uniq()
      |> Enum.drop(offset)
      |> Enum.take(per_page)

    # Then fetch the full documents with their excerpts
    from(d in Document,
      where: d.document_id in ^all_document_ids
    )
    |> Repo.all()
    |> Repo.preload(:excerpts)
  end

  @doc """
  Returns a list of all unique document types.
  """
  @spec get_document_types() :: [String.t()]
  def get_document_types do
    case Cachex.get(:documents_cache, "document_types") do
      {:ok, nil} ->
        types =
          from(d in Document,
            select: d.document_type,
            order_by: d.document_type
          )
          |> Repo.all()
          |> Enum.uniq()

        Cachex.put(:documents_cache, "document_types", types, ttl: @metadata_cache_ttl)
        types

      {:ok, types} ->
        types

      _ ->
        from(d in Document,
          select: d.document_type,
          order_by: d.document_type
        )
        |> Repo.all()
        |> Enum.uniq()
    end
  end

  @doc """
  Returns a list of all unique publishers.
  """
  @spec get_publishers() :: [String.t()]
  def get_publishers do
    case Cachex.get(:documents_cache, "publishers") do
      {:ok, nil} ->
        publishers =
          from(d in Document,
            select: d.publisher,
            order_by: d.publisher
          )
          |> Repo.all()
          |> Enum.uniq()

        Cachex.put(:documents_cache, "publishers", publishers, ttl: @metadata_cache_ttl)
        publishers

      {:ok, publishers} ->
        publishers

      _ ->
        from(d in Document,
          select: d.publisher,
          order_by: d.publisher
        )
        |> Repo.all()
        |> Enum.uniq()
    end
  end

  @doc """
  Clears the documents cache. Call this when documents are updated or deleted.
  """
  def clear_documents_cache do
    # Clear all entries in the cache
    Cachex.clear(:documents_cache)
  end

  @doc """
  Gets a single document by its ID.
  Returns nil if the document does not exist.
  """
  @spec get_document(String.t()) :: Document.t() | nil
  def get_document(document_id), do: get(Document, document_id)

  @doc """
  Gets a single document by its ID.
  Raises `Ecto.NoResultsError` if the document does not exist.
  """
  @spec get_document!(String.t()) :: Document.t() | no_return()
  def get_document!(document_id) do
    Repo.get!(Document, document_id)
    |> Repo.preload(:excerpts)
  end

  @doc """
  Creates a document.
  Returns `{:ok, document}` on success or `{:error, changeset}` on failure.
  """
  @spec create_document(map()) :: {:ok, Document.t()} | {:error, Ecto.Changeset.t()}
  def create_document(attrs \\ %{}), do: create(Document, attrs)

  @doc """
  Updates a document.
  Returns `{:ok, document}` on success or `{:error, changeset}` on failure.
  """
  @spec update_document(Document.t(), map()) :: {:ok, Document.t()} | {:error, Ecto.Changeset.t()}
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.
  Returns `{:ok, document}` on success or `{:error, changeset}` on failure.
  """
  @spec delete_document(Document.t()) :: {:ok, Document.t()} | {:error, Ecto.Changeset.t()}
  def delete_document(%Document{} = document), do: delete(document)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.
  """
  @spec change_document(Document.t(), map()) :: Ecto.Changeset.t()
  def change_document(%Document{} = document, attrs \\ %{}), do: change(document, attrs)

  # Excerpt functions
  @doc """
  Returns the list of excerpts.
  """
  @spec list_excerpts() :: [Excerpt.t()]
  def list_excerpts, do: list(Excerpt)

  @doc """
  Returns the list of excerpts for a given document.
  """
  @spec list_excerpts_by_document(String.t()) :: [Excerpt.t()]
  def list_excerpts_by_document(document_id) do
    from(e in Excerpt, where: e.document_id == ^document_id)
    |> Repo.all()
  end

  @doc """
  Gets a single excerpt by its ID.
  Returns nil if the excerpt does not exist.
  """
  @spec get_excerpt(String.t()) :: Excerpt.t() | nil
  def get_excerpt(excerpt_id), do: get(Excerpt, excerpt_id)

  @doc """
  Gets a single excerpt by its ID.
  Raises `Ecto.NoResultsError` if the excerpt does not exist.
  """
  @spec get_excerpt!(String.t()) :: Excerpt.t() | no_return()
  def get_excerpt!(excerpt_id), do: get!(Excerpt, excerpt_id)

  @doc """
  Creates an excerpt.
  Returns `{:ok, excerpt}` on success or `{:error, changeset}` on failure.
  """
  @spec create_excerpt(map()) :: {:ok, Excerpt.t()} | {:error, Ecto.Changeset.t()}
  def create_excerpt(attrs \\ %{}), do: create(Excerpt, attrs)

  @doc """
  Updates an excerpt.
  Returns `{:ok, excerpt}` on success or `{:error, changeset}` on failure.
  """
  @spec update_excerpt(Excerpt.t(), map()) :: {:ok, Excerpt.t()} | {:error, Ecto.Changeset.t()}
  def update_excerpt(%Excerpt{} = excerpt, attrs) do
    excerpt
    |> Excerpt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an excerpt.
  Returns `{:ok, excerpt}` on success or `{:error, changeset}` on failure.
  """
  @spec delete_excerpt(Excerpt.t()) :: {:ok, Excerpt.t()} | {:error, Ecto.Changeset.t()}
  def delete_excerpt(%Excerpt{} = excerpt), do: delete(excerpt)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking excerpt changes.
  """
  @spec change_excerpt(Excerpt.t(), map()) :: Ecto.Changeset.t()
  def change_excerpt(%Excerpt{} = excerpt, attrs \\ %{}), do: change(excerpt, attrs)

  @doc """
  Preloads categories for a list of excerpts or a single excerpt.
  """
  @spec preload_categories([Excerpt.t()]) :: [Excerpt.t()]
  @spec preload_categories(Excerpt.t()) :: Excerpt.t()
  def preload_categories(excerpts) when is_list(excerpts) do
    Repo.preload(excerpts, :category)
  end

  def preload_categories(excerpt) do
    Repo.preload(excerpt, :category)
  end

  @doc """
  Returns a list of documents filtered by document type.
  """
  @spec list_documents_by_type(String.t(), keyword() | map()) :: {[Document.t()], integer()}
  def list_documents_by_type(document_type, opts \\ []) do
    list_documents([document_type: document_type] ++ opts)
  end

  @doc """
  Returns a list of documents filtered by publisher.
  """
  @spec list_documents_by_publisher(String.t(), keyword() | map()) :: {[Document.t()], integer()}
  def list_documents_by_publisher(publisher, opts \\ []) do
    list_documents([publisher: publisher] ++ opts)
  end
end

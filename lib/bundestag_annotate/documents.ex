defmodule BundestagAnnotate.Documents do
  @moduledoc """
  The Documents context provides functions for managing documents and their excerpts.
  """

  use BundestagAnnotate.BaseContext
  alias BundestagAnnotate.Documents.{Document, Excerpt}
  import Ecto.Query
  alias BundestagAnnotate.Repo

  # Document functions
  @doc """

  Returns a list of documents. When options are provided, returns a tuple with pagination info.
  """
  @spec list_documents() :: [Document.t()]
  @spec list_documents(map()) :: {[Document.t()], integer()}
  def list_documents(opts \\ []) do
    if opts == [] do
      Repo.all(Document)
      |> Repo.preload(:excerpts)
    else
      page = Keyword.get(opts, :page, 1)
      per_page = Keyword.get(opts, :per_page, 10)
      sort_order = Keyword.get(opts, :sort_order, "desc")
      has_excerpts = Keyword.get(opts, :has_excerpts, true)
      offset = (page - 1) * per_page

      IO.puts("list_documents - page: #{page}, per_page: #{per_page}, offset: #{offset}")

      # Base query
      base_query =
        from d in Document,
          left_join: e in assoc(d, :excerpts)

      # Apply sorting
      base_query =
        case sort_order do
          "asc" ->
            from [d, _] in base_query, order_by: [asc: d.date]

          "categorized" ->
            from [d, e] in base_query,
              group_by: d.document_id,
              order_by: [desc: count(e.category_id)]

          "uncategorized" ->
            from [d, e] in base_query,
              group_by: d.document_id,
              order_by: [asc: count(e.category_id)]

          _ ->
            from [d, _] in base_query, order_by: [desc: d.date]
        end

      # Apply filters
      base_query =
        if has_excerpts do
          from [d, e] in base_query,
            group_by: d.document_id,
            having: count(e.excerpt_id) > 0
        else
          from [d, _] in base_query,
            group_by: d.document_id
        end

      # Get total count
      total_count =
        base_query
        |> select([d], d.document_id)
        |> Repo.all()
        |> length()

      # Get paginated documents with their excerpts
      documents =
        base_query
        |> select([d], d)
        |> limit(^per_page)
        |> offset(^offset)
        |> Repo.all()
        |> Repo.preload(:excerpts)

      # Log the first few dates to verify sorting
      dates = Enum.map(documents, & &1.date)
      IO.puts("First 3 dates: #{inspect(Enum.take(dates, 3))}")

      {documents, total_count}
    end
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
end

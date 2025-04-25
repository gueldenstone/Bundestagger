defmodule BundestagAnnotate.Documents do
  @moduledoc """
  The Documents context provides functions for managing documents and their excerpts.
  """

  use BundestagAnnotate.BaseContext
  alias BundestagAnnotate.Documents.{Document, Excerpt}

  # Document functions
  @doc """
  Returns the list of documents.
  """
  @spec list_documents() :: [Document.t()]
  def list_documents, do: list(Document)

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
  def get_document!(document_id), do: get!(Document, document_id)

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

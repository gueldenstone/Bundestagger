defmodule BundestagAnnotate.Documents do
  import Ecto.Query, warn: false
  alias BundestagAnnotate.Repo
  alias BundestagAnnotate.Documents.{Document, Excerpt}

  # Document functions
  def list_documents do
    Repo.all(Document)
  end

  def get_document(document_id), do: Repo.get(Document, document_id)
  def get_document!(document_id), do: Repo.get!(Document, document_id)

  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  # Excerpt functions
  def list_excerpts do
    Repo.all(Excerpt)
  end

  def list_excerpts_by_document(document_id) do
    from(e in Excerpt, where: e.document_id == ^document_id)
    |> Repo.all()
  end

  def get_excerpt(excerpt_id), do: Repo.get(Excerpt, excerpt_id)
  def get_excerpt!(excerpt_id), do: Repo.get!(Excerpt, excerpt_id)

  def create_excerpt(attrs \\ %{}) do
    %Excerpt{}
    |> Excerpt.changeset(attrs)
    |> Repo.insert()
  end

  def update_excerpt(%Excerpt{} = excerpt, attrs) do
    excerpt
    |> Excerpt.changeset(attrs)
    |> Repo.update()
  end

  def delete_excerpt(%Excerpt{} = excerpt) do
    Repo.delete(excerpt)
  end
end

defmodule BundestagAnnotate.Documents do
  import Ecto.Query, warn: false
  alias BundestagAnnotate.Repo
  alias BundestagAnnotate.Documents.{Document, Excerpt, Category}

  # Category functions
  def list_categories do
    Repo.all(Category)
  end

  def get_category(category_id), do: Repo.get(Category, category_id)
  def get_category!(category_id), do: Repo.get!(Category, category_id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

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

  def preload_categories(excerpts) when is_list(excerpts) do
    Repo.preload(excerpts, :category)
  end

  def preload_categories(excerpt) do
    Repo.preload(excerpt, :category)
  end
end

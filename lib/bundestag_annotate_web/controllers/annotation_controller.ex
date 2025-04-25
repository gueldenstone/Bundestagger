defmodule BundestagAnnotateWeb.AnnotationController do
  use BundestagAnnotateWeb, :controller

  alias BundestagAnnotate.{Documents, Categories}

  def index(conn, _params) do
    documents =
      Documents.list_documents()
      |> Enum.map(fn document ->
        excerpts =
          Documents.list_excerpts_by_document(document.document_id)
          |> Documents.preload_categories()

        all_categorized = Enum.all?(excerpts, & &1.category)
        Map.put(document, :all_categorized, all_categorized)
      end)

    render(conn, :index, documents: documents)
  end

  def show(conn, %{"id" => document_id}) do
    redirect(conn, to: ~p"/documents/#{document_id}")
  end

  def select_category(conn, %{"excerpt-id" => excerpt_id, "category-id" => category_id}) do
    excerpt = Documents.get_excerpt!(excerpt_id)
    category = Categories.get_category!(category_id)

    case Documents.update_excerpt(excerpt, %{category_id: category.category_id}) do
      {:ok, _excerpt} ->
        conn
        |> put_flash(:info, "Category selected successfully")
        |> redirect(to: ~p"/documents/#{excerpt.document_id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to select category")
        |> redirect(to: ~p"/documents/#{excerpt.document_id}")
    end
  end
end

defmodule BundestagAnnotateWeb.AnnotationController do
  use BundestagAnnotateWeb, :controller

  alias BundestagAnnotate.{Documents, Categories}

  def index(conn, params) do
    {documents, total_count} = Documents.list_documents(params)

    render(conn, :index,
      documents: documents,
      total_count: total_count,
      page: String.to_integer(Map.get(params, "page", "1")),
      per_page: String.to_integer(Map.get(params, "per_page", "10")),
      sort_by: Map.get(params, "sort_by", "date"),
      sort_order: Map.get(params, "sort_order", "desc"),
      has_excerpts: Map.get(params, "has_excerpts", "true")
    )
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

defmodule BundestagAnnotateWeb.AnnotationController do
  use BundestagAnnotateWeb, :controller

  alias BundestagAnnotate.Documents

  def index(conn, _params) do
    documents = Documents.list_documents()
    render(conn, :index, documents: documents)
  end

  def show(conn, %{"id" => document_id}) do
    document = Documents.get_document!(document_id)
    excerpts = Documents.list_excerpts_by_document(document_id)
    render(conn, :show, document: document, excerpts: excerpts)
  end
end

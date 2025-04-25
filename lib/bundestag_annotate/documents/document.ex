defmodule BundestagAnnotate.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:document_id, :string, autogenerate: false}
  schema "documents" do
    field :date, :date
    field :title, :string
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:document_id, :date, :title, :content])
    |> validate_required([:document_id, :date, :title, :content])
  end
end

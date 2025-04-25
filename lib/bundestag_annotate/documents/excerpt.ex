defmodule BundestagAnnotate.Documents.Excerpt do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:excerpt_id, :string, autogenerate: false}
  schema "excerpts" do
    field :sentence_before, :string
    field :sentence_with_keyword, :string
    field :sentence_after, :string

    belongs_to :document, BundestagAnnotate.Documents.Document,
      type: :string,
      foreign_key: :document_id,
      references: :document_id

    timestamps()
  end

  @doc false
  def changeset(excerpt, attrs) do
    excerpt
    |> cast(attrs, [
      :excerpt_id,
      :document_id,
      :sentence_before,
      :sentence_with_keyword,
      :sentence_after
    ])
    |> validate_required([:excerpt_id, :document_id, :sentence_with_keyword])
    |> foreign_key_constraint(:document_id)
  end
end

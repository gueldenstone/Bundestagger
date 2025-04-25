defmodule BundestagAnnotate.Documents.Excerpt do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:excerpt_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "excerpts" do
    field :sentence_before, :string
    field :sentence_with_keyword, :string
    field :sentence_after, :string

    belongs_to :document, BundestagAnnotate.Documents.Document,
      foreign_key: :document_id,
      references: :document_id,
      type: :binary_id

    belongs_to :category, BundestagAnnotate.Documents.Category,
      foreign_key: :category_id,
      references: :category_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(excerpt, attrs) do
    excerpt
    |> cast(attrs, [
      :sentence_before,
      :sentence_with_keyword,
      :sentence_after,
      :document_id,
      :category_id
    ])
    |> validate_required([:sentence_with_keyword, :document_id])
    |> foreign_key_constraint(:document_id)
    |> foreign_key_constraint(:category_id)
  end
end

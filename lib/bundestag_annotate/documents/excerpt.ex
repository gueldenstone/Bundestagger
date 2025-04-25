defmodule BundestagAnnotate.Documents.Excerpt do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          excerpt_id: String.t(),
          sentence_before: String.t() | nil,
          sentence_with_keyword: String.t(),
          sentence_after: String.t() | nil,
          document_id: String.t(),
          category_id: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:excerpt_id, :string, autogenerate: false}
  schema "excerpts" do
    field :sentence_before, :string
    field :sentence_with_keyword, :string
    field :sentence_after, :string

    belongs_to :document, BundestagAnnotate.Documents.Document,
      type: :string,
      foreign_key: :document_id,
      references: :document_id

    belongs_to :category, BundestagAnnotate.Documents.Category,
      type: :string,
      foreign_key: :category_id,
      references: :category_id

    timestamps()
  end

  @doc false
  def changeset(excerpt, attrs) do
    excerpt
    |> cast(attrs, [
      :excerpt_id,
      :document_id,
      :category_id,
      :sentence_before,
      :sentence_with_keyword,
      :sentence_after
    ])
    |> validate_required([:excerpt_id, :document_id, :sentence_with_keyword])
    |> foreign_key_constraint(:document_id)
    |> foreign_key_constraint(:category_id)
  end
end

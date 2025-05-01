defmodule BundestagAnnotate.Documents.Excerpt do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          excerpt_id: binary(),
          sentence_before: String.t(),
          sentence_with_keyword: String.t(),
          sentence_after: String.t(),
          keyword: String.t(),
          document_id: binary(),
          category_id: binary() | nil,
          is_duplicate: boolean(),
          document: BundestagAnnotate.Documents.Document.t() | Ecto.Association.NotLoaded.t(),
          category:
            BundestagAnnotate.Documents.Category.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:excerpt_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "excerpts" do
    field :sentence_before, :string
    field :sentence_with_keyword, :string
    field :sentence_after, :string
    field :keyword, :string
    field :is_duplicate, :boolean, default: false

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
      :keyword,
      :document_id,
      :category_id,
      :is_duplicate
    ])
    |> validate_required([:sentence_with_keyword, :document_id, :keyword])
    |> foreign_key_constraint(:document_id)
    |> foreign_key_constraint(:category_id)
  end
end

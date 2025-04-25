defmodule BundestagAnnotate.Documents.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          category_id: String.t(),
          name: String.t(),
          description: String.t(),
          color: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:category_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :description, :string
    field :color, :string

    has_many :excerpts, BundestagAnnotate.Documents.Excerpt,
      foreign_key: :category_id,
      references: :category_id

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :color])
    |> validate_required([:name, :description, :color])
  end
end

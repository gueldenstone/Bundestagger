defmodule BundestagAnnotate.Documents.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:category_id, :string, autogenerate: false}
  schema "categories" do
    field :name, :string
    field :description, :string
    field :color, :string

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_id, :name, :description, :color])
    |> validate_required([:category_id, :name, :description, :color])
  end
end

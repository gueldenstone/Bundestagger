defmodule BundestagAnnotate.Documents.Document do
  @moduledoc """
  Schema for documents that contain excerpts to be annotated.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          document_id: String.t() | nil,
          title: String.t() | nil,
          content: String.t() | nil,
          date: Date.t() | nil,
          excerpts: [BundestagAnnotate.Documents.Excerpt.t()] | Ecto.Association.NotLoaded,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:document_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "documents" do
    field :date, :date
    field :title, :string
    field :content, :string

    has_many :excerpts, BundestagAnnotate.Documents.Excerpt,
      foreign_key: :document_id,
      references: :document_id

    timestamps()
  end

  @doc """
  Creates a changeset for a document.
  """
  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = document, attrs) do
    document
    |> cast(attrs, [:date, :title, :content])
    |> validate_required([:date, :title, :content])
    |> validate_length(:title, min: 1, max: 255)
    |> unique_constraint(:document_id)
  end
end

defmodule BundestagAnnotate.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add :document_id, :string, primary_key: true
      add :date, :date, null: false
      add :title, :string, null: false
      add :content, :text, null: false

      timestamps()
    end
  end
end

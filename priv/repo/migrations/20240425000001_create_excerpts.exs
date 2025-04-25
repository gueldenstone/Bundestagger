defmodule BundestagAnnotate.Repo.Migrations.CreateExcerpts do
  use Ecto.Migration

  def change do
    create table(:excerpts, primary_key: false) do
      add :excerpt_id, :string, primary_key: true
      add :document_id, references(:documents, type: :string, column: :document_id), null: false
      add :sentence_before, :text
      add :sentence_with_keyword, :text, null: false
      add :sentence_after, :text

      timestamps()
    end

    create index(:excerpts, [:document_id])
  end
end

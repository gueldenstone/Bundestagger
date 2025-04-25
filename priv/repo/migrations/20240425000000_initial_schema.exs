defmodule BundestagAnnotate.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    # Enable foreign key support for SQLite
    execute "PRAGMA foreign_keys = ON"

    # Create categories table first (no foreign key dependencies)
    create table(:categories, primary_key: false) do
      add :category_id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text, null: false
      add :color, :string, null: false

      timestamps()
    end

    # Create documents table second (no foreign key dependencies)
    create table(:documents, primary_key: false) do
      add :document_id, :binary_id, primary_key: true
      add :date, :date, null: false
      add :title, :string, null: false
      add :content, :text, null: false

      timestamps()
    end

    # Create excerpts table last (depends on both categories and documents)
    create table(:excerpts, primary_key: false) do
      add :excerpt_id, :binary_id, primary_key: true
      add :document_id, :binary_id, null: false
      add :category_id, :binary_id, null: false
      add :sentence_before, :text
      add :sentence_with_keyword, :text, null: false
      add :sentence_after, :text

      timestamps()
    end

    # Create indexes
    create index(:excerpts, [:document_id])
    create index(:excerpts, [:category_id])

    # Create foreign key constraints using SQLite's syntax
    execute """
    CREATE TRIGGER fk_excerpts_document_id
    BEFORE INSERT ON excerpts
    BEGIN
      SELECT CASE
        WHEN (SELECT document_id FROM documents WHERE document_id = NEW.document_id) IS NULL
        THEN RAISE(ABORT, 'foreign key constraint failed')
      END;
    END;
    """

    execute """
    CREATE TRIGGER fk_excerpts_category_id
    BEFORE INSERT ON excerpts
    BEGIN
      SELECT CASE
        WHEN (SELECT category_id FROM categories WHERE category_id = NEW.category_id) IS NULL
        THEN RAISE(ABORT, 'foreign key constraint failed')
      END;
    END;
    """
  end
end

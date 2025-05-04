defmodule BundestagAnnotate.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    # Add indexes for frequently queried columns
    create index(:documents, [:date])
    create index(:documents, [:document_type])
    create index(:documents, [:publisher])
    create index(:excerpts, [:is_duplicate])

    # Add composite index for common query patterns
    create index(:documents, [:document_type, :publisher, :date])

    # Add index for excerpt filtering
    create index(:excerpts, [:document_id, :category_id])
  end
end

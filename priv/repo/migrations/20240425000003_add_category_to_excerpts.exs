defmodule BundestagAnnotate.Repo.Migrations.AddCategoryToExcerpts do
  use Ecto.Migration

  def change do
    alter table(:excerpts) do
      add :category_id, references(:categories, type: :string, column: :category_id)
    end

    create index(:excerpts, [:category_id])
  end
end

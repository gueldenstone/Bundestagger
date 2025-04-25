defmodule BundestagAnnotate.Repo.Migrations.AddKeywordToExcerpts do
  use Ecto.Migration

  def change do
    alter table(:excerpts) do
      add :keyword, :string, null: false
    end
  end
end

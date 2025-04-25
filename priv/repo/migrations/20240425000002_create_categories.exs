defmodule BundestagAnnotate.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :category_id, :string, primary_key: true
      add :name, :string, null: false
      add :description, :text, null: false
      add :color, :string, null: false

      timestamps()
    end
  end
end

defmodule BundestagAnnotate.Categories do
  @moduledoc """
  The Categories context provides functions for managing annotation categories.
  """

  use BundestagAnnotate.BaseContext
  alias BundestagAnnotate.Documents.Category

  @doc """
  Returns the list of categories.
  """
  @spec list_categories() :: [Category.t()]
  def list_categories, do: list(Category)

  @doc """
  Gets a single category by its ID.
  Returns nil if the category does not exist.
  """
  @spec get_category(String.t()) :: Category.t() | nil
  def get_category(category_id), do: get(Category, category_id)

  @doc """
  Gets a single category by its ID.
  Raises `Ecto.NoResultsError` if the category does not exist.
  """
  @spec get_category!(String.t()) :: Category.t() | no_return()
  def get_category!(category_id), do: get!(Category, category_id)

  @doc """
  Creates a category.
  Returns `{:ok, category}` on success or `{:error, changeset}` on failure.
  """
  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}), do: create(Category, attrs)

  @doc """
  Updates a category.
  Returns `{:ok, category}` on success or `{:error, changeset}` on failure.
  """
  @spec update_category(Category.t(), map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.
  Returns `{:ok, category}` on success or `{:error, changeset}` on failure.
  """
  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category), do: delete(category)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.
  """
  @spec change_category(Category.t(), map()) :: Ecto.Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}), do: change(category, attrs)
end

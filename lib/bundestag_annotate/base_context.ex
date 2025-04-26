defmodule BundestagAnnotate.BaseContext do
  @moduledoc """
  Base context module providing common functionality for all contexts.
  """

  @type t :: struct()

  defmacro __using__(_) do
    quote do
      import Ecto.Query, warn: false
      alias BundestagAnnotate.Repo

      @doc """
      Returns a list of all records.
      """
      @spec list(module()) :: [struct()]
      def list(schema) do
        Repo.all(schema)
      end

      @doc """
      Gets a single record by ID.
      Returns nil if the record does not exist.
      """
      @spec get(module(), String.t()) :: struct() | nil
      def get(schema, id), do: Repo.get(schema, id)

      @doc """
      Gets a single record by ID.
      Raises `Ecto.NoResultsError` if the record does not exist.
      """
      @spec get!(module(), String.t()) :: struct() | no_return()
      def get!(schema, id), do: Repo.get!(schema, id)

      @doc """
      Creates a record.
      Returns `{:ok, record}` on success or `{:error, changeset}` on failure.
      """
      @spec create(module(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
      def create(schema, attrs \\ %{}) do
        struct(schema)
        |> schema.changeset(attrs)
        |> Repo.insert()
      end

      @doc """
      Updates a record.
      Returns `{:ok, record}` on success or `{:error, changeset}` on failure.
      """
      @spec update(struct(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
      def update(record, attrs) do
        record
        |> record.__struct__.changeset(attrs)
        |> Repo.update()
      end

      @doc """
      Deletes a record.
      Returns `{:ok, record}` on success or `{:error, changeset}` on failure.
      """
      @spec delete(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
      def delete(record) do
        Repo.delete(record)
      end

      @doc """
      Returns an `%Ecto.Changeset{}` for tracking record changes.
      """
      @spec change(struct(), map()) :: Ecto.Changeset.t()
      def change(record, attrs \\ %{}) do
        record.__struct__.changeset(record, attrs)
      end

      defoverridable list: 1, get: 2, get!: 2, create: 2, update: 2, delete: 1, change: 2
    end
  end
end

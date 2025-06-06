defmodule BundestagAnnotate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BundestagAnnotateWeb.Telemetry,
      BundestagAnnotate.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:bundestag_annotate, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster,
       query: Application.get_env(:bundestag_annotate, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BundestagAnnotate.PubSub},
      # Start Cachex for document caching
      {Cachex, name: :documents_cache},
      # Start a worker by calling: BundestagAnnotate.Worker.start_link(arg)
      # {BundestagAnnotate.Worker, arg},
      # Start to serve requests, typically the last entry
      BundestagAnnotateWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BundestagAnnotate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BundestagAnnotateWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @impl true
  def stop(_state) do
    # Ensure database connections are properly closed
    :ok = BundestagAnnotate.Repo.stop()
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end

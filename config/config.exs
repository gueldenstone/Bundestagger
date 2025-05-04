# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bundestag_annotate,
  ecto_repos: [BundestagAnnotate.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure SQLite3 adapter
config :bundestag_annotate, BundestagAnnotate.Repo,
  pool_size: 5,
  busy_timeout: 5000,
  journal_mode: :wal,
  synchronous: :normal

# Configures the endpoint
config :bundestag_annotate, BundestagAnnotateWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BundestagAnnotateWeb.ErrorHTML, json: BundestagAnnotateWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BundestagAnnotate.PubSub,
  live_view: [signing_salt: "e/vuMcht"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  bundestag_annotate: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :exqlite, force_build: true

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  bundestag_annotate: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

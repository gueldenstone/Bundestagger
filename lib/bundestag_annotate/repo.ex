defmodule BundestagAnnotate.Repo do
  use Ecto.Repo,
    otp_app: :bundestag_annotate,
    adapter: Ecto.Adapters.SQLite3
end

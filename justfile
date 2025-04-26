default:
    just --list

install-deps:
    mix setup

run_dev:
    iex -S mix phx.server

run_prod:
    MIX_ENV=prod iex -S mix phx.server

reset_db:
    mix ecto.reset

migrate_db:
    mix ecto.migrate

seed_db:
    mix run priv/repo/seeds.exs

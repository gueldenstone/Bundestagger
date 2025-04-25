set shell := ["nix", "develop", ".", "--command", "bash", "-c"]

default:
    just --list

install-deps:
    mix setup

run-dev:
    iex -S mix phx.server

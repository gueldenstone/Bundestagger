# Build stage
FROM hexpm/elixir:1.16.1-erlang-26.2.1-alpine-3.19.0 AS build

# Install build dependencies
RUN apk add --no-cache build-base git

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy assets
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Copy priv directory
COPY priv priv

# Copy lib directory
COPY lib lib

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release

# App stage
FROM alpine:3.19.0 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Create a non-root user
RUN chown nobody:nobody /app

USER nobody:nobody

# Copy the release from the build stage
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/bundestag_annotate ./
COPY --from=build --chown=nobody:nobody /app/priv/static ./priv/static

# Create data directory for SQLite database
RUN mkdir -p /app/data

# Set environment variables
ENV HOME=/app
ENV MIX_ENV=prod
ENV PHX_SERVER=true
ENV PORT=4000
ENV DATABASE_PATH=/app/data/bundestag_annotate.db

# Expose the port
EXPOSE 4000

# Start the application
CMD ["bin/bundestag_annotate", "start"] 

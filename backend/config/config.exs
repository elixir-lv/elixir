# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elixir_backend,
  ecto_repos: [ElixirBackend.Repo]

# Configures the endpoint
config :elixir_backend, ElixirBackend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Fy+M/f67SJWGjoUEG4NrBN8P8X+2ODzdGkbDcxRIeDjPxh8HbBX+TkvqH25ZbEtd",
  render_errors: [view: ElixirBackend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ecto_example,
  ecto_repos: [EctoExample.Repo]

# Configures the endpoint
config :ecto_example, EctoExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2LYRJRjmjLRLyPOvzeUUynqOuB+LrmwJaPTJ6utgyj8UD2hlLzvAOmFR0aRVOGlY",
  render_errors: [view: EctoExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: EctoExample.PubSub,
  live_view: [signing_salt: "Xf2/Jmnk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :danilla, DanillaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "q+ecYYG0cI1mi/1jHx7DQHa6A/afBWVZPXlBBzGr0so6m9xz8cpAfUYUDPUWRE1L",
  render_errors: [view: DanillaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Danilla.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure round for bcrypt_elixir
config :bcrypt_elixir, log_rounds: 6

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

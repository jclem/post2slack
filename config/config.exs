use Mix.Config

config :post2slack,
  post_signing_secret: {:system, "POST_SIGNING_SECRET"},
  state_signing_secret: {:system, "STATE_SIGNING_SECRET"}

config :post2slack, Post2Slack.Router,
  port: {:system, "PORT"},
  redirect_uri: {:system, "SLACK_REDIRECT_URI"}

config :post2slack, Slack,
  client_id: {:system, "SLACK_CLIENT_ID"},
  client_secret: {:system, "SLACK_CLIENT_SECRET"}

import_config "#{Mix.env()}.exs"

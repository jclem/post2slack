use Mix.Config

config :post2slack,
  post_signing_secret: "bjjO6+V7s2aB75C/59fB+eqSwERtmbral/bJjn9XV5g=",
  state_signing_secret: "WIfuFwwR3aMBPV2viOc8DfOIzVQYNstxHymUq8pzVRc="

config :post2slack, Post2Slack.Router, redirect_uri: "https://localhost"

config :post2slack, Slack,
  client_id: "SLACK_CLIENT_ID",
  client_secret: "SLACK_CLIENT_SECRET"

config :logger, level: :error

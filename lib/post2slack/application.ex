require Logger

defmodule Post2Slack.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Config.fetch!(:post2slack, :port) |> String.to_integer()

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Post2Slack.Router,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: Post2Slack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

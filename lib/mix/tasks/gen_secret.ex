defmodule Mix.Tasks.Post2Slack.Gen.Secret do
  use Mix.Task

  @shortdoc "Generate a secret for Post2Slack"
  def run(_) do
    :crypto.strong_rand_bytes(32) |> Base.encode64() |> IO.write()
  end
end

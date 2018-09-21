defmodule Post2Slack.ApplicationTest do
  use ExUnit.Case, async: false

  test "it can be started" do
    Application.put_env(:post2slack, :port, "9000")
    Post2Slack.Application.start(1, 2)
    Post2Slack.Application.stop(:stop)
  end
end

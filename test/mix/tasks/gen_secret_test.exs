defmodule Mix.Tasks.Post2Slack.Gen.SecretTest do
  use ExUnit.Case, async: false

  import Mock

  describe ".run/1" do
    test_with_mock "it returns a base64-encoded 32-byte key", IO, write: fn value -> value end do
      value = Mix.Tasks.Post2Slack.Gen.Secret.run([])
      {:ok, decoded} = Base.decode64(value)
      assert byte_size(decoded) == 32
    end
  end
end

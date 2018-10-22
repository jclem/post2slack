defmodule Post2Slack.StateTokenTest do
  use ExUnit.Case, async: true

  import Joken

  alias Joken.Token
  alias Post2Slack.StateToken

  test ".create_token/1" do
    compact = StateToken.create_token()
    assert StateToken.verify_token(compact) == :ok
  end

  describe ".verify_token/2" do
    test "verifies a valid token" do
      compact = StateToken.create_token()
      assert StateToken.verify_token(compact) == :ok
    end

    test "errors for an invalid token" do
      token =
        Joken.token(%{foo: "bar"})
        |> Joken.with_signer(Joken.hs256("HELLO"))
        |> Joken.sign()
        |> Joken.get_compact()

      assert StateToken.verify_token(token) == {:error, :invalid_token}
    end

    test "errors for an invalid iat" do
      token =
        %Token{}
        |> with_signer(hs256(Config.fetch!(:post2slack, :state_signing_secret)))
        |> with_iat(current_time() + 60)
        |> with_exp(current_time())
        |> sign
        |> get_compact

      assert StateToken.verify_token(token) == {:error, :invalid_token}
    end

    test "errors for an expired token" do
      token =
        %Token{}
        |> with_signer(hs256(Config.fetch!(:post2slack, :state_signing_secret)))
        |> with_iat(current_time())
        |> with_exp(current_time() - 60)
        |> sign
        |> get_compact

      assert StateToken.verify_token(token) == {:error, :invalid_token}
    end

    test "errors for an improper token" do
      assert StateToken.verify_token("HI") == {:error, :invalid_token}
    end
  end
end

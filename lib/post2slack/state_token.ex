require Logger

defmodule Post2Slack.StateToken do
  import Joken

  alias Joken.Token

  @spec create_token :: String.t()
  def create_token do
    time = current_time()

    %Token{}
    |> add_signer()
    |> with_iat(time)
    |> with_exp(time + 240)
    |> sign
    |> get_compact
  end

  @spec verify_token(String.t()) :: :ok | {:error, :invalid_token}
  def verify_token(compact) do
    compact
    |> token()
    |> add_signer()
    |> with_validation("exp", &(&1 > current_time() - 60), "Token expired")
    |> with_validation("iat", &(&1 < current_time() + 60), "Token invalid")
    |> verify()
    |> case do
      %{error: nil, errors: []} ->
        :ok

      %{errors: errors} when errors != [] ->
        errors |> inspect |> Logger.warn()
        {:error, :invalid_token}

      %{error: error} when error != nil ->
        error |> inspect |> Logger.warn()
        {:error, :invalid_token}
    end
  end

  defp add_signer(token) do
    secret = Config.fetch!(:post2slack, :state_signing_secret)
    with_signer(token, hs256(secret))
  end
end

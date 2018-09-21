defmodule Post2Slack.PostToken do
  alias JOSE.{JWE, JWK}

  @one_week 604_800

  @spec create_token(String.t()) :: String.t()
  def create_token(oauth_token) do
    time = current_time()

    claims = %{"oauth_token" => oauth_token, "iat" => time, "exp" => time + @one_week}
    jwk = JWK.from_oct(get_secret())
    jws = %{"alg" => "A256GCMKW", "enc" => "A256GCM"}
    {_, token} = JWE.block_encrypt(jwk, Poison.encode!(claims), jws) |> JWE.compact()
    token
  end

  @spec verify_token(String.t()) :: {:ok, String.t()} | {:error, :invalid_token}
  def verify_token(compact) do
    jwk = JWK.from_oct(get_secret())
    time = current_time()

    with {encoded, _} <- JWE.block_decrypt(jwk, compact),
         {:ok, %{"exp" => exp, "iat" => iat, "oauth_token" => oauth_token}} <-
           Poison.decode(encoded),
         true <- iat < time + 60,
         true <- exp > time do
      {:ok, oauth_token}
    else
      _ -> {:error, :invalid_token}
    end
  end

  defp get_secret do
    Config.fetch!(:post2slack, :post_signing_secret)
    |> Base.decode64!()
  end

  defp current_time do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end

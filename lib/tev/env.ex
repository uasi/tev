defmodule Tev.Env do
  def twitter_api_key!, do: get_env!("TWITTER_API_KEY")
  def twitter_api_secret!, do: get_env!("TWITTER_API_SECRET")

  defp get_env!(name) do
    System.get_env(name) || raise("Environment variable #{name} is not set")
  end
end

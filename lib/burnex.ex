defmodule Burnex do
  @moduledoc """
  Elixir burner email (temporary address) detector.
  List from https://github.com/wesbos/burner-email-providers/blob/master/emails.txt
  """

  @external_resource "priv/burner-email-providers/emails.txt"

  @providers @external_resource
             |> File.read!()
             |> String.split("\n")
             |> Enum.filter(fn str -> str != "" end)

  @doc """
  Check if email is a temporary / burner address.

  ## Examples

      iex> Burnex.is_burner?("my-email@gmail.com")
      false
      iex> Burnex.is_burner?("my-email@yopmail.fr")
      true
      iex> Burnex.is_burner? "invalid.format.yopmail.fr"
      false
  """
  @spec is_burner?(binary()) :: boolean()
  def is_burner?(email) do
    case Regex.run(~r/@([^@]+)$/, String.downcase(email)) do
      [_ | [provider]] ->
        Enum.any?(@providers, &Kernel.==(provider, &1))

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Returns the list of all blacklisted domains providers
  """
  @spec providers() :: nonempty_list(binary())
  def providers() do
    @providers
  end
end

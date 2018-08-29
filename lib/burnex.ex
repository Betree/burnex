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
      [_ | [domain]] ->
        is_burner_domain(domain)

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Check a domain

  ## Examples

      iex> Burnex.is_burner_domain("yopmail.fr")
      true
      iex> Burnex.is_burner_domain("")
      false
      iex> Burnex.is_burner_domain("gmail.com")
      false
  """
  @spec is_burner_domain(binary()) :: boolean()
  def is_burner_domain(domain) do
    Enum.any?(@providers, &Kernel.==(domain, &1))
  end

  @doc """
  Returns the list of all blacklisted domains providers
  """
  @spec providers() :: nonempty_list(binary())
  def providers do
    @providers
  end
end

defmodule Burnex do
  @moduledoc """
  Elixir burner email (temporary address) detector.
  List from https://github.com/wesbos/burner-email-providers/blob/master/emails.txt
  """

  @dialyzer {:nowarn_function, is_burner_domain?: 1}

  @external_resource "priv/burner-email-providers/emails.txt"

  @providers @external_resource
             |> File.read!()
             |> String.split("\n")
             |> Enum.filter(fn str -> str != "" end)
             |> MapSet.new()

  @doc """
  Check if email is a temporary / burner address.

  Optionally resolve the MX record

  ## Examples

      iex> Burnex.is_burner?("my-email@gmail.com")
      false
      iex> Burnex.is_burner?("my-email@yopmail.fr")
      true
      iex> Burnex.is_burner? "invalid.format.yopmail.fr"
      false
      iex> Burnex.is_burner?("my-email@gmail.fr", true)
      {true, "Cannot find MX record"}
  """
  @spec is_burner?(binary(), boolean()) :: boolean()
  def is_burner?(email, resolve_mx_record \\ false) do
    case Regex.run(~r/@([^@]+)$/, String.downcase(email)) do
      [_ | [domain]] ->
        is_burner_domain?(domain) or (resolve_mx_record and is_burner_mx_record?(domain))

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Check a domain

  ## Examples

      iex> Burnex.is_burner_domain?("yopmail.fr")
      true
      iex> Burnex.is_burner_domain?("")
      false
      iex> Burnex.is_burner_domain?("gmail.com")
      false
  """
  @spec is_burner_domain?(binary()) :: boolean()
  def is_burner_domain?(domain) do
    case MapSet.member?(@providers, domain) do
      false ->
        case Regex.run(~r/^[^.]+[.](.*)$/, domain) do
          [_ | [higher_domain]] ->
            is_burner_domain?(higher_domain)

          nil ->
            false
        end

      true ->
        true
    end
  end

  @doc """
  Returns the list of all blacklisted domains providers
  """
  def providers do
    @providers
  end

  defp bad_mx_server_domains(mx_resolution) do
    Enum.filter(mx_resolution, fn {_port, server_domain} ->
      server_domain
      |> to_string()
      |> is_burner_domain?()
    end)
  end

  @spec is_burner_mx_record?(binary()) :: boolean() | {boolean(), binary()}
  def is_burner_mx_record?(domain) do
    with {:dns_resolve, {:ok, mx_resolution}} <- {:dns_resolve, DNS.resolve(domain, :mx)},
         {:bad_server_domains, []} <- {:bad_server_domains, bad_mx_server_domains(mx_resolution)} do
      false
    else
      {:dns_resolve, _} ->
        {true, "Cannot find MX record"}

      {:bad_server_domains, bad_server_domains} ->
        {true,
         "Forbidden MX server(s): " <>
           Enum.join(
             Enum.map(bad_server_domains, fn {_port, server} -> server end),
             ", "
           )}
    end
  rescue
    Socket.Error -> {true, "MX record search timed out"}
  end
end

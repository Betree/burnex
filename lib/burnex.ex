defmodule Burnex do
  @external_resource readme = "README.md"
  @moduledoc readme
             |> File.read!()
             |> String.split("<!--MDOC !-->")
             |> Enum.fetch!(1)

  @external_resource emails = "priv/burner-email-providers/emails.txt"
  @providers emails
             |> File.read!()
             |> String.split("\n")
             |> Enum.filter(fn str -> str != "" end)
             |> MapSet.new()

  @dialyzer {:nowarn_function, is_burner_domain?: 1}

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

  """
  @spec is_burner?(binary()) :: boolean()
  def is_burner?(email) do
    case Regex.run(~r/@([^@]+)$/, String.downcase(email)) do
      [_ | [domain]] ->
        is_burner_domain?(domain)

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Check a domain is a burner domain.

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
  Returns the list of all blacklisted domains providers.

  ## Examples

      iex> Burnex.providers()
      #MapSet<["mysunrise.tech", "gmailom.co", "renwoying.org",
      "xn--c3cralk2a3ak7a5gghbv.com", "ghork.live", "wellnessmarketing.solutions",
      "zerograv.top", "votenoonnov6.com", "b45win.org", "muslimahcollection.online",
      ...]>

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

  @spec check_domain_mx_record(binary()) :: :ok | {:error, binary()}
  def check_domain_mx_record(domain) do
    with {:dns_resolve, {:ok, mx_resolution}} <- {:dns_resolve, DNS.resolve(domain, :mx)},
         {:bad_server_domains, []} <- {:bad_server_domains, bad_mx_server_domains(mx_resolution)} do
      :ok
    else
      {:dns_resolve, _} ->
        {:error, "Cannot find MX record"}

      {:bad_server_domains, bad_server_domains} ->
        {:error,
         "Forbidden MX server(s): " <>
           Enum.join(
             Enum.map(bad_server_domains, fn {_port, server} -> server end),
             ", "
           )}
    end
  rescue
    Socket.Error -> {:error, "MX record search timed out"}
  end
end

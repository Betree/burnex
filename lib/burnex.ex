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
        case Regex.run(~r/^[^.]+[.](.+)$/, domain) do
          [_ | [higher_domain]] ->
            is_burner_domain?(higher_domain)

          _ ->
            false
        end

      true ->
        true
    end
  end

  @doc """
  Returns a MapSet with all blocked domains providers.

  ## Examples

      iex> Burnex.providers()
      #MapSet<["mysunrise.tech", "gmailom.co", "renwoying.org", "xn--c3cralk2a3ak7a5gghbv.com", "vevevevevery.ru", "ghork.live", "totobaksa.website", "wellnessmarketing.solutions", "zerograv.top", "votenoonnov6.com", "b45win.org", "dataleak01.site", "muslimahcollection.online", "barcntenef.ml", "lpi1iyi7m3zfb0i.gq", "ceco3kvloj5s3.tk", "outlettomsshoesstore.com", "kebabishcosladacoslada.com", "utoo.email", "pedia-egypt.org", "bestmemory.net", "8263813.com", "hz6m.com", "anocor.gq", "charltons.biz", "qvady.network", "2v3vjqapd6itot8g4z.gq", "yliora.site", "ectseep.site", "2m46.space", "godrejpropertiesforestgrove.com", "smart-thailand.com", "takebacktheregent.com", "dozarb.online", "mail22.space", "ttsbcq.us", "clubhowse.com", "gayflorida.net", "specialsshorts.info", "dubainaturalsoap.com", "carolynlove.website", "jlqiqd.tokyo", "kulitlumpia8.cf", "adastralflying.com", "superstachel.de", "diyarbakirengelliler.xyz", "notatempmail.info", "directproductinvesting.com", "francisxkelly.com", "saclouisvuittonboutiquefrance.com", ...]>

  """
  def providers do
    @providers
  end

  @spec check_domain_mx_record(binary()) :: :ok | {:error, binary()}
  def check_domain_mx_record(domain) do
    case :inet_res.lookup(to_charlist(domain), :any, :mx) do 
      [] -> {:error, "Cannot find MX records"}
      mx_records -> check_bad_mx_server_domains(mx_records)
    end
  end

  defp check_bad_mx_server_domains(mx_records) do
    mx_records
    |> Enum.map(fn {_port, domain} -> to_string(domain) end)
    |> Enum.filter(fn domain -> is_burner_domain?(domain) end)
    |> mx_server_check_response()
  end

  defp mx_server_check_response([]), do: :ok
  defp mx_server_check_response(domains) do
    {:error, "Forbidden MX server(s): " <> Enum.join(domains, ", ")}
  end
end

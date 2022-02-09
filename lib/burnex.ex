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

  @inet_res_opts [
    {:alt_nameservers, [
      {{1,1,1,1}, 53}, # Cloudflare primary
      {{8,8,8,8}, 53}, # Google primary
      {{1,0,0,1}, 53}, # Cloudflare secondary
      {{8,8,4,4}, 53}  # Google secondary
    ]}
  ]

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

      #MapSet<["alivemail.ga", "nalds.live", "unalstore.xyz", "studiodesain.me", "betofis111.com", "gehu.site", "6q70sdpgjzm2irltn.tk", "zomg.info", "spingenie.org", "analyticalwe.us", "dickwangdong.net", "ezzzi.com", "caroil-promo.xyz", "enfsmq2wel.cf", "eagleinbox.com", "hikeeastcoasttrail.com", "indumento.club", "ro-na.com", "freebeautyofsweden.se", "gratislink.net", "bluetree.holiday", "alamedahomealarm.com", "waredbarn.com", "letslearnarduino.com", "folderiowa.com", "ufcticket.ru", "iqsfu65qbbkrioew.tk", "guzzthickfull.tk", "stanmody.ga", "erothde.gq", "nat4.us", "vnuova.icu", "wertuoicikax8.site", "0nedrive.ml", "tarjetasdecredito.company", "0374445.com", "lottoegg.live", "698424.com", "dfet356ads1.ml", "d9jdnvyk1m6audwkgm.tk", "rc94stgoffreg1.com", "langleyrecord.org", "mailed.ro", "sltmail.com", "dogfishmail.com", "vologdalestopprom.ru", "gnomebots.com", "cu8wzkanv7.cf", "czaresy.info", "7p6kz0omk2kb6fs8lst.tk", ...]>

  """
  def providers do
    @providers
  end

  @spec check_domain_mx_record(binary()) :: :ok | {:error, binary()}
  def check_domain_mx_record(domain) do
    case :inet_res.lookup(to_charlist(domain), :any, :mx, @inet_res_opts, 5_000) do
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

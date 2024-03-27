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
    {:alt_nameservers,
     [
       # Cloudflare primary
       {{1, 1, 1, 1}, 53},
       # Google primary
       {{8, 8, 8, 8}, 53},
       # Cloudflare secondary
       {{1, 0, 0, 1}, 53},
       # Google secondary
       {{8, 8, 4, 4}, 53}
     ]}
  ]

  @typep option :: {:providers, MapSet.t()}

  @doc """
  Check if email is a temporary / burner address.

  Optionally resolve the MX record

  ## Options

   * providers - (set of domains) this option specifies
   burner email domains to match against. Defaults to:
   [list of domains](https://github.com/Betree/burnex/blob/master/priv/burner-email-providers/emails.txt)

  ## Examples

      iex> Burnex.is_burner?("my-email@gmail.com")
      false
      iex> Burnex.is_burner?("my-email@yopmail.fr")
      true
      iex> Burnex.is_burner? "invalid.format.yopmail.fr"
      false

  """
  @spec is_burner?(binary(), list(option)) :: boolean()
  def is_burner?(email, opts \\ []) when is_list(opts) do
    providers = Keyword.get(opts, :providers, @providers)

    case Regex.run(~r/@([^@]+)$/, String.downcase(email)) do
      [_ | [domain]] ->
        is_burner_domain?(domain, providers: providers)

      _ ->
        # Bad email format
        false
    end
  end

  @doc """
  Check a domain is a burner domain.

  ## Options

   * providers - (set of domains) this option specifies
   burner email domains to match against. Defaults to:
   [list of domains](https://github.com/Betree/burnex/blob/master/priv/burner-email-providers/emails.txt)

  ## Examples

      iex> Burnex.is_burner_domain?("yopmail.fr")
      true
      iex> Burnex.is_burner_domain?("")
      false
      iex> Burnex.is_burner_domain?("gmail.com")
      false

  """
  @spec is_burner_domain?(binary(), list(option)) :: boolean()
  def is_burner_domain?(domain, opts \\ [])

  def is_burner_domain?(domain, opts) when is_list(opts) and is_binary(domain) do
    providers = Keyword.get(opts, :providers, @providers)

    case MapSet.member?(providers, domain) do
      false ->
        case Regex.run(~r/^[^.]+[.](.+)$/, domain) do
          [_ | [higher_domain]] ->
            is_burner_domain?(higher_domain, providers: providers)

          _ ->
            false
        end

      true ->
        true
    end
  end

  def is_burner_domain?(_domain, _opts), do: true

  @doc """
  Returns a MapSet with all blocked domains providers.

  ## Examples

      iex> Burnex.providers() |> MapSet.member?("yopmail.fr")
      true
  """
  def providers do
    @providers
  end

  @spec check_domain_mx_record(binary(), list(option)) :: :ok | {:error, binary()}
  def check_domain_mx_record(domain, opts \\ []) when is_list(opts) do
    providers = Keyword.get(opts, :providers, @providers)

    case :inet_res.lookup(to_charlist(domain), :in, :mx, @inet_res_opts, 5_000) do
      [] -> {:error, "Cannot find MX records"}
      mx_records -> check_bad_mx_server_domains(mx_records, providers: providers)
    end
  end

  defp check_bad_mx_server_domains(mx_records, opts) do
    providers = Keyword.get(opts, :providers, @providers)

    mx_records
    |> Enum.map(fn {_port, domain} -> to_string(domain) end)
    |> Enum.filter(fn domain -> is_burner_domain?(domain, providers: providers) end)
    |> mx_server_check_response()
  end

  defp mx_server_check_response([]), do: :ok

  defp mx_server_check_response(domains) do
    {:error, "Forbidden MX server(s): " <> Enum.join(domains, ", ")}
  end
end

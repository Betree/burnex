# Burnex

<!--MDOC !-->

[![Build Status](https://github.com/Betree/burnex/workflows/Test/badge.svg)](https://github.com/Betree/burnex/actions)
[![Coverage Status](https://coveralls.io/repos/github/Betree/burnex/badge.svg?branch=master)](https://coveralls.io/github/Betree/burnex?branch=master)
[![Module Version](https://img.shields.io/hexpm/v/burnex.svg)](https://hex.pm/packages/burnex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/burnex/)
[![Total Download](https://img.shields.io/hexpm/dt/burnex.svg)](https://hex.pm/packages/burnex)
[![License](https://img.shields.io/hexpm/l/burnex.svg)](https://hex.pm/packages/burnex)
[![Last Updated](https://img.shields.io/github/last-commit/Betree/burnex.svg)](https://github.com/Betree/burnex/commits/master)

Compare an email address against 3900+ burner email domains (temporary email
providers) based on this list from
[https://github.com/wesbos/burner-email-providers](https://github.com/wesbos/burner-email-providers).

## Installation

Add `:burnex` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:burnex, "~> 3.1.0"}
  ]
end
```

## Usage

Be aware that Burnex will not check if the email is RFC compliant, it will only
check the domain (everything that comes after `@`).

```elixir
iex> Burnex.is_burner?("my-email@gmail.com")
false
iex> Burnex.is_burner?("my-email@yopmail.fr")
true
iex> Burnex.is_burner? "invalid.format.yopmail.fr"
false
iex> Burnex.is_burner? "\"this is a valid address! crazy right ?\"@yopmail.fr"
true

iex> Burnex.providers
#MapSet<["mysunrise.tech", "gmailom.co", "renwoying.org", "xn--c3cralk2a3ak7a5gghbv.com", "vevevevevery.ru", "ghork.live", "totobaksa.website", "wellnessmarketing.solutions", "zerograv.top", "votenoonnov6.com", "b45win.org", "dataleak01.site", "muslimahcollection.online", "barcntenef.ml", "lpi1iyi7m3zfb0i.gq", "ceco3kvloj5s3.tk", "outlettomsshoesstore.com", "kebabishcosladacoslada.com", "utoo.email", "pedia-egypt.org", "bestmemory.net", "8263813.com", "hz6m.com", "anocor.gq", "charltons.biz", "qvady.network", "2v3vjqapd6itot8g4z.gq", "yliora.site", "ectseep.site", "2m46.space", "godrejpropertiesforestgrove.com", "smart-thailand.com", "takebacktheregent.com", "dozarb.online", "mail22.space", "ttsbcq.us", "clubhowse.com", "gayflorida.net", "specialsshorts.info", "dubainaturalsoap.com", "carolynlove.website", "jlqiqd.tokyo", "kulitlumpia8.cf", "adastralflying.com", "superstachel.de", "diyarbakirengelliler.xyz", "notatempmail.info", "directproductinvesting.com", "francisxkelly.com", "saclouisvuittonboutiquefrance.com", ...]>
```

### With an Ecto changeset

Following code ensures email has a valid format then check if it belongs to a burner provider:

```elixir
def changeset(model, params) do
  model
  |> cast(params, @required_fields ++ @optional_fields)
  |> validate_required([:email])
  |> validate_email()
end

@email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

defp validate_email(%{changes: %{email: email}} = changeset) do
  case Regex.match?(@email_regex, email) do
    true ->
      case Burnex.is_burner?(email) do
        true -> add_error(changeset, :email, "forbidden_provider")
        false -> changeset
      end
    false -> add_error(changeset, :email, "invalid_format")
  end
end
defp validate_email(changeset), do: changeset
```

### MX record DNS resolution

As an extra precaution against newly-created burner domains,
you can use Burnex to do MX record DNS resolution.
This is done like this:

```
iex> Burnex.check_domain_mx_record("gmail.com")
:ok
iex> Burnex.check_domain_mx_record("gmail.fr")
{:error, "Cannot find MX record"}
```

Here is an example function to check if an email is valid:

```elixir
  # Use a regex capture to get the "domain" part of an email
  @email_regex ~r/^\S+@(\S+\.\S+)$/

  # hard-code some trusted domains to avoid checking their MX record every time
  @good_email_domains [
    "gmail.com",
    "fastmail.com"
  ]

  defp email_domain(email), do: Regex.run(@email_regex, String.downcase(email))

  defp is_not_burner?(email, domain) do
    with {:is_burner, false} <- {:is_burner, Burnex.is_burner?(email)},
         {:check_mx_record, :ok} <- {:check_mx_record, Burnex.check_domain_mx_record(domain)} do
      true
    else
      {:is_burner, true} ->
        {false, "forbidden email"}

      {:check_mx_record, {:error, error_message}} when is_binary(error_message) ->
        {false, error_message}

      {:check_mx_record, :error} ->
        {false, "forbidden provider"}
    end
  end

  @spec is_valid?(String.t()) :: true | {false, String.t()}
  def is_valid?(email) do
    case email_domain(email) do
      [_ | [domain]] ->
        case domain in @good_email_domains do
          true ->
            true

          false ->
            is_not_burner?(email, domain)
        end

      _ ->
        {false, "Email in bad format"}
    end
  end
```


## License

This software is licensed under MIT license. Copyright (c) 2018- Benjamin Piouffle.

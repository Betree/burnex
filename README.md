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
#MapSet<["alivemail.ga", "nalds.live", "unalstore.xyz", "studiodesain.me", "betofis111.com", "gehu.site", "6q70sdpgjzm2irltn.tk", "zomg.info", "spingenie.org", "analyticalwe.us", "dickwangdong.net", "ezzzi.com", "caroil-promo.xyz", "enfsmq2wel.cf", "eagleinbox.com", "hikeeastcoasttrail.com", "indumento.club", "ro-na.com", "freebeautyofsweden.se", "gratislink.net", "bluetree.holiday", "alamedahomealarm.com", "waredbarn.com", "letslearnarduino.com", "folderiowa.com", "ufcticket.ru", "iqsfu65qbbkrioew.tk", "guzzthickfull.tk", "stanmody.ga", "erothde.gq", "nat4.us", "vnuova.icu", "wertuoicikax8.site", "0nedrive.ml", "tarjetasdecredito.company", "0374445.com", "lottoegg.live", "698424.com", "dfet356ads1.ml", "d9jdnvyk1m6audwkgm.tk", "rc94stgoffreg1.com", "langleyrecord.org", "mailed.ro", "sltmail.com", "dogfishmail.com", "vologdalestopprom.ru", "gnomebots.com", "cu8wzkanv7.cf", "czaresy.info", "7p6kz0omk2kb6fs8lst.tk", ...]>
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
iex> Burnex.check_domain_mx_record("gmail.dklfsd")
{:error, "Cannot find MX records"}
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
      [_ | [domain]] when domain in @good_email_domains ->
        true

      [_ | [domain]] ->
        is_not_burner?(email, domain)

      _ ->
        {false, "Email in bad format"}
    end
  end
```

## License

This software is licensed under MIT license. Copyright (c) 2018- Benjamin Piouffle.

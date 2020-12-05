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
    {:burnex, "~> 1.0"}
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
#MapSet<["mysunrise.tech", "gmailom.co", "renwoying.org",
"xn--c3cralk2a3ak7a5gghbv.com", "ghork.live", "wellnessmarketing.solutions",
"zerograv.top", "votenoonnov6.com", "b45win.org", "muslimahcollection.online",
...]>
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
you can user Burnex to do MX record DNS resolution.
This is done like this:

```
iex> Burnex.check_domain_mx_record("gmail.com")
:ok
iex> Burnex.check_domain_mx_record("gmail.fr")
{:error, "Cannot find MX record"}
```

## License

This software is licensed under MIT license. Copyright (c) 2018- Benjamin Piouffle.

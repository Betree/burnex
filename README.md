# Burnex

[![Build Status](https://github.com/Betree/burnex/workflows/Test/badge.svg)](https://github.com/Betree/burnex/actions)
[![Coverage Status](https://coveralls.io/repos/github/Betree/burnex/badge.svg?branch=master)](https://coveralls.io/github/Betree/burnex?branch=master)

Compare an email address against 3900+ burner email domains (temporary email providers) based on
[this list](https://github.com/wesbos/burner-email-providers).

See [documentation](https://hexdocs.pm/burnex/Burnex.html).

## Installation

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
["001.igg.biz", "027168.com", "0815.ru", "0815.ry", "0815.su", "0845.ru",
 "0box.eu", "0clickemail.com", "0-mail.com", "0mixmail.info", "0u.ro", "0v.ro",
 "0w.ro", "0wnd.net", "0wnd.org", "0x00.name", "0x207.info",
 "1000rebates.stream", "100likers.com", "10host.top", "10mail.com",
 "10mail.org", "10minut.com.pl", "10minutemail.be", "10minutemail.cf",
 "10minutemail.co.uk", "10minutemail.co.za", "10minutemail.com",
 "10minutemail.de", "10minutemail.ga", "10minutemail.gq", "10minutemail.info",
 "10minutemail.ml", "10minutemail.net", "10minutemail.nl", "10minutemail.org",
 "10minutemail.ru", "10minutemail.us", "10minutemailbox.com",
 "10minutenemail.de", "10minutesmail.com", "10minutesmail.fr",
 "10minutesmail.net", "10minutesmail.ru", "10vpn.info", "10x.es", "10x9.com",
 "11top.xyz", "123-m.com", "126.com", ...]
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
def validate_email(changeset), do: changeset
```

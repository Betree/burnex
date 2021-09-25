defmodule BurnexTest do
  @moduledoc """
  Tests for `Burnex` module.
  """

  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest Burnex

  test "example: filters jetable.org" do
    assert Burnex.is_burner?("test@jetable.org")
  end

  test "strictly compare domain" do
    providers = Burnex.providers()
    refute Burnex.is_burner?("myemail@not_temporary_" <> Enum.random(providers))
  end

  test "with strange emails" do
    # As ugly as it is, these are valid email formats
    assert Burnex.is_burner?("\"forbidden@email\"@yopmail.fr")
    assert Burnex.is_burner?("\"this is valid! crazy right ?\"@yopmail.fr")
  end

  test "with subdomains" do
    assert Burnex.is_burner?("hello@mail2.mailinator.com")
    assert Burnex.is_burner?("hello@reject2.maildrop.cc")
  end

  test "providers list should never be empty" do
    refute Enum.empty?(Burnex.providers())
  end

  test "providers list should not contains empty values" do
    refute Enum.any?(Burnex.providers(), &(String.length(&1) == 0))
  end

  test "providers should always be lowercase" do
    refute Enum.any?(Burnex.providers(), &(String.downcase(&1) != &1))
  end

  test "should respect passed providers" do
    good_provider = Burnex.providers() |> Enum.random()
    providers = Burnex.providers() |> MapSet.delete(good_provider)

    refute Burnex.is_burner?("test@" <> good_provider, providers: providers)
  end

  property "doesn't explode if email has bad format" do
    check all(email <- StreamData.string(:alphanumeric)) do
      refute Burnex.is_burner?(email)
    end
  end

  property "should always detect emails with blocked providers" do
    check all(email <- email_generator(Burnex.providers())) do
      assert Burnex.is_burner?(email)
    end
  end

  property "is not fooled by uppercase domains" do
    check all(email <- email_generator(Burnex.providers())) do
      assert Burnex.is_burner?(String.upcase(email))
    end
  end

  @valid_providers ["gmail.com", "live.fr", "protonmail.com", "outlook.com"]
  property "should always return false for valid providers" do
    check all(email <- email_generator(@valid_providers)) do
      refute Burnex.is_burner?(email)
    end
  end

  describe "mx record validation" do
    test "correctly resolves domains with bad MX records" do
      assert Burnex.check_domain_mx_record("jetable.org") ==
               {:error, "Forbidden MX server(s): mx.jetable.org"}
    end

    test "correctly resolves domains missing MX records" do
      assert Burnex.check_domain_mx_record("somenonesensedomain.blahblahblah") ==
               {:error, "Cannot find MX record"}
    end

    test "correctly resolves domains with 'good' MX records" do
      [
        "gmail.com",
        "hotmail.com"
      ]
      |> Enum.each(fn good_domain ->
        assert Burnex.check_domain_mx_record(good_domain) == :ok,
               "#{good_domain} should have a good mailserver with valid MX record"
      end)
    end
  end

  # ---- Helpers ----

  defp email_generator(providers) do
    ExUnitProperties.gen all(
                           name <- StreamData.string(:alphanumeric),
                           domain <- StreamData.member_of(providers)
                         ) do
      name <> "@" <> domain
    end
  end
end

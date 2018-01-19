defmodule BurnexTest do
  use ExUnit.Case, async: true
  doctest Burnex

  test "filters bad emails providers" do
    assert Burnex.is_burner?("myemail@" <> Enum.random(Burnex.providers))
  end

  test "example: filters jetable.org" do
    assert Burnex.is_burner?("test@jetable.org")
  end

  test "strictly compare domain" do
    providers = Burnex.providers()
    refute Burnex.is_burner?("myemail@not_temporary_" <> Enum.random(providers))
  end

  test "returns false when email has bad format (simple check, not full regex)" do
    assert Burnex.is_burner?("myemail@gmail.com@gmail.com")
  end
end

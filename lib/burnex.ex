defmodule Burnex do
  @moduledoc """
  Elixir burner email (temporary address) detector.
  List from https://github.com/wesbos/burner-email-providers/blob/master/emails.txt
  """

  @providers String.split(File.read!("priv/burner-email-providers/emails.txt"), "\n")

  def is_burner?(email) do
    case String.split(email, "@") do
      [_ | [provider]] ->
        Enum.any?(@providers, &Kernel.==(provider, &1))
      _ ->
        true # Bad email format
    end
  end

  def providers() do
    @providers
  end
end

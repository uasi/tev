defmodule Tev.CryptoTest do
  use ExUnit.Case, async: true

  alias Tev.Crypto

  test "encrypt and decrypt" do
    data = <<>>
    encrypted = Crypto.encrypt(data)
    assert data == Crypto.decrypt(encrypted)

    data = :crypto.strong_rand_bytes(42)
    encrypted = Crypto.encrypt(data)
    assert data == Crypto.decrypt(encrypted)
  end
end

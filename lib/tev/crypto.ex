defmodule Tev.Crypto do
  alias Tev.Env

  @doc """
  Encrypts the given data using AES-256 CBC and returns encrypted data with random 16-byte IV prepended.

  32-byte encryption key must be set to the `CRYPTO_AES256_KEY` environment variable, Base64 encoded. Raises `RuntimeError` otherwise.
  """
  @spec encrypt(binary) :: binary
  def encrypt(plaintext) do
    iv = get_random_iv
    iv <> encrypt_aes256(plaintext, get_aes256_key!, iv)
  end

  @doc """
  Decrypts the given data which is encrypted by `encrypt/1`.

  32-byte encryption key must be set to the `CRYPTO_AES256_KEY` environment variable, Base64 encoded. Raises `RuntimeError` otherwise.
  """
  @spec decrypt(binary) :: binary
  def decrypt(ciphertext_iv_prepended) do
    <<iv :: binary-size(16), ciphertext :: binary>> = ciphertext_iv_prepended
    decrypt_aes256(ciphertext, get_aes256_key!, iv)
  end

  defp encrypt_aes256(plaintext, key, iv) do
    plaintext
    |> add_padding
    |> do_crypt(:encrypt, key, iv)
  end

  defp decrypt_aes256(ciphertext, key, iv) do
    ciphertext
    |> do_crypt(:decrypt, key, iv)
    |> strip_padding
  end

  defp do_crypt(text, op, key, iv) do
    apply(:crypto, :"block_#{op}", [:aes_cbc128, key, iv, text])
  end

  defp add_padding(plaintext) do
    pad = 16 - rem(byte_size(plaintext), 16)
    plaintext <> :binary.copy(<<pad>>, pad)
  end

  defp strip_padding(plaintext) when byte_size(plaintext) == 0, do: <<>>
  defp strip_padding(plaintext) do
    pad = :binary.last(plaintext)
    body_size = byte_size(plaintext) - pad
    :binary.part(plaintext, 0, body_size)
  end

  @spec get_aes256_key! :: binary
  defp get_aes256_key! do
    key = Env.crypto_aes256_key! |> :base64.decode
    unless byte_size(key) == 32, do: raise "Key length must be 32 bytes"
    key
  end

  @spec get_random_iv :: binary
  defp get_random_iv do
    :crypto.strong_rand_bytes(16)
  end
end

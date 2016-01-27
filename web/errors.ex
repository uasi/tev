defmodule Tev.Errors do
  def raise_unauthorized(attrs \\ []) do
    raise Tev.UnauthorizedError, attrs
  end

  def raise_forbidden(attrs \\ []) do
    raise Tev.ForbiddenError, attrs
  end
end

defmodule Tev.UnauthorizedError do
  defexception plug_status: 401, message: "Unauthorized", conn: nil, router: nil
end

defmodule Tev.ForbiddenError do
  defexception plug_status: 403, message: "Forbidden", conn: nil, router: nil
end

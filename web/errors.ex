defmodule Tev.Errors do
  @spec raise_unauthorized([term]) :: no_return
  def raise_unauthorized(attrs \\ []) do
    raise Tev.UnauthorizedError, attrs
  end

  @spec raise_forbidden([term]) :: no_return
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

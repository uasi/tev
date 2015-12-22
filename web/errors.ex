defmodule Tev.UnauthorizedError do
  defexception plug_status: 401, message: "Unauthorized", conn: nil, router: nil
end

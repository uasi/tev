defmodule Tev.UnauthorizedError do
  defexception plug_status: 401, message: "Unauthorized", conn: nil, router: nil
end

defmodule Tev.ForbiddenError do
  defexception plug_status: 403, message: "Forbidden", conn: nil, router: nil
end

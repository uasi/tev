defmodule Tev.ApiView do
  use Tev.Web, :view

  import Ecto.Query

  alias Tev.PageView

  def rendered_tweets(conn, params, user) do
    %{page: page} = PageView.new(params, user)
    html = render_to_string(PageView, "_boxes.html", page_entries: page.entries)
    %{
      html: html,
      next_page: PageView.next_page_number(page),
    }
  end
end

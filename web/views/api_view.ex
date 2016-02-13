defmodule Tev.ApiView do
  use Tev.Web, :view

  alias Tev.PageView

  def rendered_tweets(params, user, timeline_type) do
    %{page: page} = PageView.new(params, user, timeline_type)
    html = render_to_string(PageView, "_boxes.html", page_entries: page.entries)
    %{
      html: html,
      next_page: PageView.next_page_number(page),
    }
  end
end

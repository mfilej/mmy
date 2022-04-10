defmodule RidleWeb.PageController do
  use RidleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

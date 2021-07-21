defmodule EctoExampleWeb.PageController do
  use EctoExampleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

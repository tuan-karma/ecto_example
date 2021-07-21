defmodule EctoExampleWeb.FallbackController do
  use EctoExampleWeb, :controller

  def call(conn, {:error, msg}) when is_binary(msg) do
    conn
    |> put_flash(:error, msg)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def call(conn, nil) do
    conn
    |> put_flash(:error, "Not Found")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end

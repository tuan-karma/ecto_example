defmodule EctoExampleWeb.NAVController do
  use EctoExampleWeb, :controller

  alias EctoExample.Tests
  alias EctoExample.Tests.NAV

  def index(conn, _params) do
    navs = Tests.list_navs()
    render(conn, "index.html", navs: navs)
  end

  def new(conn, _params) do
    changeset = Tests.change_nav(%NAV{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"nav" => nav_params}) do
    case Tests.create_nav(nav_params) do
      {:ok, nav} ->
        conn
        |> put_flash(:info, "Nav created successfully.")
        |> redirect(to: Routes.nav_path(conn, :show, nav))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    nav = Tests.get_nav!(id)
    render(conn, "show.html", nav: nav)
  end

  def edit(conn, %{"id" => id}) do
    nav = Tests.get_nav!(id)
    changeset = Tests.change_nav(nav)
    render(conn, "edit.html", nav: nav, changeset: changeset)
  end

  def update(conn, %{"id" => id, "nav" => nav_params}) do
    nav = Tests.get_nav!(id)

    case Tests.update_nav(nav, nav_params) do
      {:ok, nav} ->
        conn
        |> put_flash(:info, "Nav updated successfully.")
        |> redirect(to: Routes.nav_path(conn, :show, nav))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", nav: nav, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    nav = Tests.get_nav!(id)
    {:ok, _nav} = Tests.delete_nav(nav)

    conn
    |> put_flash(:info, "Nav deleted successfully.")
    |> redirect(to: Routes.nav_path(conn, :index))
  end
end

defmodule EctoExampleWeb.NAVControllerTest do
  use EctoExampleWeb.ConnCase

  alias EctoExample.Tests

  @create_attrs %{nav: 42, total_nav: 42, total_units_number: 120.5}
  @update_attrs %{nav: 43, total_nav: 43, total_units_number: 456.7}
  @invalid_attrs %{nav: nil, total_nav: nil, total_units_number: nil}

  def fixture(:nav) do
    {:ok, nav} = Tests.create_nav(@create_attrs)
    nav
  end

  describe "index" do
    test "lists all navs", %{conn: conn} do
      conn = get(conn, Routes.nav_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Navs"
    end
  end

  describe "new nav" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.nav_path(conn, :new))
      assert html_response(conn, 200) =~ "New Nav"
    end
  end

  describe "create nav" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.nav_path(conn, :create), nav: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.nav_path(conn, :show, id)

      conn = get(conn, Routes.nav_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Nav"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.nav_path(conn, :create), nav: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Nav"
    end
  end

  describe "edit nav" do
    setup [:create_nav]

    test "renders form for editing chosen nav", %{conn: conn, nav: nav} do
      conn = get(conn, Routes.nav_path(conn, :edit, nav))
      assert html_response(conn, 200) =~ "Edit Nav"
    end
  end

  describe "update nav" do
    setup [:create_nav]

    test "redirects when data is valid", %{conn: conn, nav: nav} do
      conn = put(conn, Routes.nav_path(conn, :update, nav), nav: @update_attrs)
      assert redirected_to(conn) == Routes.nav_path(conn, :show, nav)

      conn = get(conn, Routes.nav_path(conn, :show, nav))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, nav: nav} do
      conn = put(conn, Routes.nav_path(conn, :update, nav), nav: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Nav"
    end
  end

  describe "delete nav" do
    setup [:create_nav]

    test "deletes chosen nav", %{conn: conn, nav: nav} do
      conn = delete(conn, Routes.nav_path(conn, :delete, nav))
      assert redirected_to(conn) == Routes.nav_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.nav_path(conn, :show, nav))
      end
    end
  end

  defp create_nav(_) do
    nav = fixture(:nav)
    %{nav: nav}
  end
end

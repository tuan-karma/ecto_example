defmodule EctoExample.TestsTest do
  use EctoExample.DataCase

  alias EctoExample.Tests

  describe "navs" do
    alias EctoExample.Tests.NAV

    @valid_attrs %{nav: 42, total_nav: 42, total_units_number: 120.5}
    @update_attrs %{nav: 43, total_nav: 43, total_units_number: 456.7}
    @invalid_attrs %{nav: nil, total_nav: nil, total_units_number: nil}

    def nav_fixture(attrs \\ %{}) do
      {:ok, nav} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tests.create_nav()

      nav
    end

    test "list_navs/0 returns all navs" do
      nav = nav_fixture()
      assert Tests.list_navs() == [nav]
    end

    test "get_nav!/1 returns the nav with given id" do
      nav = nav_fixture()
      assert Tests.get_nav!(nav.id) == nav
    end

    test "create_nav/1 with valid data creates a nav" do
      assert {:ok, %NAV{} = nav} = Tests.create_nav(@valid_attrs)
      assert nav.nav == 42
      assert nav.total_nav == 42
      assert nav.total_units_number == 120.5
    end

    test "create_nav/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tests.create_nav(@invalid_attrs)
    end

    test "update_nav/2 with valid data updates the nav" do
      nav = nav_fixture()
      assert {:ok, %NAV{} = nav} = Tests.update_nav(nav, @update_attrs)
      assert nav.nav == 43
      assert nav.total_nav == 43
      assert nav.total_units_number == 456.7
    end

    test "update_nav/2 with invalid data returns error changeset" do
      nav = nav_fixture()
      assert {:error, %Ecto.Changeset{}} = Tests.update_nav(nav, @invalid_attrs)
      assert nav == Tests.get_nav!(nav.id)
    end

    test "delete_nav/1 deletes the nav" do
      nav = nav_fixture()
      assert {:ok, %NAV{}} = Tests.delete_nav(nav)
      assert_raise Ecto.NoResultsError, fn -> Tests.get_nav!(nav.id) end
    end

    test "change_nav/1 returns a nav changeset" do
      nav = nav_fixture()
      assert %Ecto.Changeset{} = Tests.change_nav(nav)
    end
  end
end

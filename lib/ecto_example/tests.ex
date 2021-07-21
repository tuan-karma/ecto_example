defmodule EctoExample.Tests do
  @moduledoc """
  The Tests context.
  """

  import Ecto.Query, warn: false
  alias EctoExample.Repo

  alias EctoExample.Tests.NAV

  @doc """
  Returns the list of navs.

  ## Examples

      iex> list_navs()
      [%NAV{}, ...]

  """
  def list_navs do
    Repo.all(NAV)
  end

  @doc """
  Gets a single nav.

  Raises `Ecto.NoResultsError` if the Nav does not exist.

  ## Examples

      iex> get_nav!(123)
      %NAV{}

      iex> get_nav!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nav!(id), do: Repo.get!(NAV, id)

  @doc """
  Creates a nav.

  ## Examples

      iex> create_nav(%{field: value})
      {:ok, %NAV{}}

      iex> create_nav(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nav(attrs \\ %{}) do
    %NAV{}
    |> NAV.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nav.

  ## Examples

      iex> update_nav(nav, %{field: new_value})
      {:ok, %NAV{}}

      iex> update_nav(nav, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nav(%NAV{} = nav, attrs) do
    nav
    |> NAV.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a nav.

  ## Examples

      iex> delete_nav(nav)
      {:ok, %NAV{}}

      iex> delete_nav(nav)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nav(%NAV{} = nav) do
    Repo.delete(nav)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nav changes.

  ## Examples

      iex> change_nav(nav)
      %Ecto.Changeset{data: %NAV{}}

  """
  def change_nav(%NAV{} = nav, attrs \\ %{}) do
    NAV.changeset(nav, attrs)
  end
end

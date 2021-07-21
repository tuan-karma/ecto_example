defmodule EctoExample.Tests.NAV do
  use Ecto.Schema
  import Ecto.Changeset

  schema "navs" do
    field :nav, :integer
    field :total_nav, :integer
    field :total_units_number, :float

    timestamps()
  end

  @doc false
  def changeset(nav, attrs) do
    nav
    |> cast(attrs, [:total_nav, :total_units_number, :nav])
    |> validate_required([:total_nav, :total_units_number, :nav])
  end
end

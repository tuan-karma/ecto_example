defmodule EctoExample.Repo.Migrations.CreateNavs do
  use Ecto.Migration

  def change do
    create table(:navs) do
      add :total_nav, :integer
      add :total_units_number, :float
      add :nav, :integer

      timestamps()
    end

  end
end

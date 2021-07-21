defmodule EctoExample.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :draft, :text
      add :body, :text
      add :title, :string
      add :author_id, references(:authors, on_delete: :delete_all)

      timestamps()
    end

    create index(:posts, [:author_id])
  end
end

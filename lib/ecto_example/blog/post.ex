defmodule EctoExample.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :draft, :string
    field :title, :string

    belongs_to :author, EctoExample.Blog.Author
    many_to_many :tags, EctoExample.Blog.Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:draft, :body, :title])
    |> validate_required([:draft, :body, :title])
  end
end

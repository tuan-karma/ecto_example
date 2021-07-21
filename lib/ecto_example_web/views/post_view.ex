defmodule EctoExampleWeb.PostView do
  use EctoExampleWeb, :view

  def list_authors() do
    ["Author1", "Author2", "Author3"]
  end

  def list_tags() do
    ["tag_1", "tag_2", "tag_3"]
  end
end

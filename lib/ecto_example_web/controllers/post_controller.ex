defmodule EctoExampleWeb.PostController do
  use EctoExampleWeb, :controller

  alias EctoExample.Blog
  alias EctoExample.Blog.Post

  action_fallback EctoExampleWeb.FallbackController

  def index(conn, _params) do
    posts = Blog.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Blog.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Post{} = post <- Blog.get_post(id) do
      render(conn, "show.html", post: post)
    end
  end

  def edit(conn, %{"id" => id}) do
    with %Post{} = post <- Blog.get_post(id) do
      changeset = Blog.change_post(post)
      render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    with %Post{} = post <- Blog.get_post(id) do
      case Blog.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Post{} = post <- Blog.get_post(id) do
      {:ok, _post} = Blog.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    end
  end
end

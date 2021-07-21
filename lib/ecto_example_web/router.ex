defmodule EctoExampleWeb.Router do
  use EctoExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", EctoExampleWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/blog", EctoExampleWeb do
    pipe_through :browser

    resources "/posts", PostController
  end
end

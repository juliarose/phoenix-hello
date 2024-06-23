defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, %{"messenger" => messenger}) do
    conn
    |> assign(:receiver, "Dweezil")
    |> assign(:messenger, messenger)
    |> render(:show)
  end
end

defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/create")
  end
end

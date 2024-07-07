defmodule HelloWeb.CreatePhotoLive do
  use HelloWeb, :live_view

  alias HelloWeb.PhotoFormComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

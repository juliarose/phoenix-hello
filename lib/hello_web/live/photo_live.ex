defmodule HelloWeb.PhotoLive do
  use HelloWeb, :live_view

  alias Hello.{Photos, Photos.Photo}

  def mount(%{"id" => id}, _session, socket) do
    photo = Photos.get_photo!(id)

    {:ok, socket
    |> assign(:photo, photo)
    |> assign(:photo_image_url, get_photo_image_url(photo))}
  end

  defp get_photo_image_url(photo) do
    HelloWeb.Uploaders.ImageUploader.url({photo.image, photo})
  end
end

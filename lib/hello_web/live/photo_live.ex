defmodule HelloWeb.PhotoLive do
  use HelloWeb, :live_view

  alias Hello.Photos

  def mount(%{"id" => id}, _session, socket) do
    photo = Photos.get_photo!(id)
    {:ok, relative_time} = Timex.format(photo.updated_at, "{relative}", :relative)

    photo = Map.put(photo, :relative_time, relative_time)

    {:ok, socket
    |> assign(:photo, photo)
    |> assign(:photo_image_url, get_photo_image_url(photo))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Photos.delete_photo(socket.assigns.current_user, id) do
      {:ok, _photo} ->
        socket = put_flash(socket, :info, "Photo deleted successfully")
        {:noreply, push_navigate(socket, to: ~p"/create")}
      {:error, message} ->
        socket = put_flash(socket, :error, message)
        {:noreply, socket}
    end
  end

  defp get_photo_image_url(photo) do
    HelloWeb.Uploaders.PhotoUploader.url({photo.image, photo})
  end
end

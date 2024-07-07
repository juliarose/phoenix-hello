defmodule HelloWeb.PhotoFormComponent do
  use HelloWeb, :live_component

  alias Hello.{Photos, Photos.Photo}

  def mount(socket) do
    socket = assign(
      socket,
      form: to_form(Photos.change_photo(%Photo{}))
    )
    |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 1)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="justify center px-28 w-full space-y-4 mb-10">
          <.input
            field={@form[:title]}
            placeholder="Photo title..."
            autocomplete="off"
            phx-debounce="blur"
          />

          <div class="flex items-center w-[300px] text-xs text-white">
            <.live_file_input
              upload={@uploads[:image]}
            />
          </div>

          <.input
            field={@form[:description]}
            class="w-full rounded-b-md"
            type="textarea"
            placeholder="Photo description (optional)"
            autocomplete="off"
            phx-debounce="blur"
          />
          <div class="flex justify-end">
            <button
              type="submit"
              class="rounded-md border p-2 text-white"
              phx-disable-with="Uploading..."
            >
              Upload photo
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"photo" => photo_params}, socket) do
    [file_path] =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    save_photo(socket, :save, Map.put(photo_params, "image", file_path))
  end

  def handle_event("validate", %{"photo" => photo_params}, socket) do
    changeset = %Photo{}
    |> Photos.change_photo(photo_params)
    |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  defp save_photo(socket, :save, photo_params) do
    case Photos.create_photo(socket.assigns.current_user, photo_params) do
      {:ok, photo} ->
        changeset = Photos.change_photo(%Photo{})
        socket = assign_form(socket, changeset)

        {:noreply, push_navigate(socket, to: ~p"/photos?#{[id: photo.id]}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

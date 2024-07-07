defmodule HelloWeb.Uploaders.PhotoUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @allowed_extensions ~w(.png .jpg .jpeg)

  def storage_dir(_version, {_file, _scope}) do
    "uploads/photos"
  end

  def filename(version, {file, photo}) do
    # It is desirable for this name to be unique
    "#{file.file_name}_#{photo.title}_#{version}"
  end

  def validate(_version, {file, _scope}) do
    file_extension =file.file_name
    |> Path.extname()
    |> String.downcase()

    Enum.member?(@allowed_extensions, file_extension)
  end
end

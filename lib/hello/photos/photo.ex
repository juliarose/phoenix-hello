defmodule Hello.Photos.Photo do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "photos" do
    field :title, :string
    field :description, :string
    field :image, HelloWeb.Uploaders.PhotoUploader.Type
    belongs_to :user, Hello.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :description])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:title, :image])
  end
end

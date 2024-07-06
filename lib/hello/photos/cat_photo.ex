defmodule Hello.Photos.CatPhoto do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cat_photos" do
    belongs_to :cat, Hello.Cats.Cat
    belongs_to :photo, Hello.Photos.Photo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cat_photo, attrs) do
    cat_photo
    |> cast(attrs, [:cat_id, :photo_id])
    |> validate_required([:cat_id, :photo_id])
  end
end

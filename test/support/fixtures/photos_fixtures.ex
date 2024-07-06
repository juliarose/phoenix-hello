defmodule Hello.PhotosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Photos` context.
  """

  @doc """
  Generate a photo.
  """
  def photo_fixture(attrs \\ %{}) do
    {:ok, photo} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image"
      })
      |> Hello.Photos.create_photo()

    photo
  end

  @doc """
  Generate a cat_photo.
  """
  def cat_photo_fixture(attrs \\ %{}) do
    {:ok, cat_photo} =
      attrs
      |> Enum.into(%{

      })
      |> Hello.Photos.create_cat_photo()

    cat_photo
  end
end

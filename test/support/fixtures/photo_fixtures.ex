defmodule Hello.PhotoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Photo` context.
  """

  @doc """
  Generate a cat_photo.
  """
  def cat_photo_fixture(attrs \\ %{}) do
    {:ok, cat_photo} =
      attrs
      |> Enum.into(%{

      })
      |> Hello.Photo.create_cat_photo()

    cat_photo
  end
end

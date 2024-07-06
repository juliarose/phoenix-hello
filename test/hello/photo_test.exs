defmodule Hello.PhotoTest do
  use Hello.DataCase

  alias Hello.Photo

  describe "cat_photos" do
    alias Hello.Photo.CatPhoto

    import Hello.PhotoFixtures

    @invalid_attrs %{}

    test "list_cat_photos/0 returns all cat_photos" do
      cat_photo = cat_photo_fixture()
      assert Photo.list_cat_photos() == [cat_photo]
    end

    test "get_cat_photo!/1 returns the cat_photo with given id" do
      cat_photo = cat_photo_fixture()
      assert Photo.get_cat_photo!(cat_photo.id) == cat_photo
    end

    test "create_cat_photo/1 with valid data creates a cat_photo" do
      valid_attrs = %{}

      assert {:ok, %CatPhoto{} = cat_photo} = Photo.create_cat_photo(valid_attrs)
    end

    test "create_cat_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Photo.create_cat_photo(@invalid_attrs)
    end

    test "update_cat_photo/2 with valid data updates the cat_photo" do
      cat_photo = cat_photo_fixture()
      update_attrs = %{}

      assert {:ok, %CatPhoto{} = cat_photo} = Photo.update_cat_photo(cat_photo, update_attrs)
    end

    test "update_cat_photo/2 with invalid data returns error changeset" do
      cat_photo = cat_photo_fixture()
      assert {:error, %Ecto.Changeset{}} = Photo.update_cat_photo(cat_photo, @invalid_attrs)
      assert cat_photo == Photo.get_cat_photo!(cat_photo.id)
    end

    test "delete_cat_photo/1 deletes the cat_photo" do
      cat_photo = cat_photo_fixture()
      assert {:ok, %CatPhoto{}} = Photo.delete_cat_photo(cat_photo)
      assert_raise Ecto.NoResultsError, fn -> Photo.get_cat_photo!(cat_photo.id) end
    end

    test "change_cat_photo/1 returns a cat_photo changeset" do
      cat_photo = cat_photo_fixture()
      assert %Ecto.Changeset{} = Photo.change_cat_photo(cat_photo)
    end
  end
end

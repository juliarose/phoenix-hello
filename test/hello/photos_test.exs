defmodule Hello.PhotosTest do
  use Hello.DataCase

  alias Hello.Photos

  describe "photos" do
    alias Hello.Photos.Photo

    import Hello.PhotosFixtures

    @invalid_attrs %{description: nil, image: nil}

    test "list_photos/0 returns all photos" do
      photo = photo_fixture()
      assert Photos.list_photos() == [photo]
    end

    test "get_photo!/1 returns the photo with given id" do
      photo = photo_fixture()
      assert Photos.get_photo!(photo.id) == photo
    end

    test "create_photo/1 with valid data creates a photo" do
      valid_attrs = %{description: "some description", image: "some image"}

      assert {:ok, %Photo{} = photo} = Photos.create_photo(valid_attrs)
      assert photo.description == "some description"
      assert photo.image == "some image"
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Photos.create_photo(@invalid_attrs)
    end

    test "update_photo/2 with valid data updates the photo" do
      photo = photo_fixture()
      update_attrs = %{description: "some updated description", image: "some updated image"}

      assert {:ok, %Photo{} = photo} = Photos.update_photo(photo, update_attrs)
      assert photo.description == "some updated description"
      assert photo.image == "some updated image"
    end

    test "update_photo/2 with invalid data returns error changeset" do
      photo = photo_fixture()
      assert {:error, %Ecto.Changeset{}} = Photos.update_photo(photo, @invalid_attrs)
      assert photo == Photos.get_photo!(photo.id)
    end

    test "delete_photo/1 deletes the photo" do
      photo = photo_fixture()
      assert {:ok, %Photo{}} = Photos.delete_photo(photo)
      assert_raise Ecto.NoResultsError, fn -> Photos.get_photo!(photo.id) end
    end

    test "change_photo/1 returns a photo changeset" do
      photo = photo_fixture()
      assert %Ecto.Changeset{} = Photos.change_photo(photo)
    end
  end

  describe "cat_photos" do
    alias Hello.Photos.CatPhoto

    import Hello.PhotosFixtures

    @invalid_attrs %{}

    test "list_cat_photos/0 returns all cat_photos" do
      cat_photo = cat_photo_fixture()
      assert Photos.list_cat_photos() == [cat_photo]
    end

    test "get_cat_photo!/1 returns the cat_photo with given id" do
      cat_photo = cat_photo_fixture()
      assert Photos.get_cat_photo!(cat_photo.id) == cat_photo
    end

    test "create_cat_photo/1 with valid data creates a cat_photo" do
      valid_attrs = %{}

      assert {:ok, %CatPhoto{} = cat_photo} = Photos.create_cat_photo(valid_attrs)
    end

    test "create_cat_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Photos.create_cat_photo(@invalid_attrs)
    end

    test "update_cat_photo/2 with valid data updates the cat_photo" do
      cat_photo = cat_photo_fixture()
      update_attrs = %{}

      assert {:ok, %CatPhoto{} = cat_photo} = Photos.update_cat_photo(cat_photo, update_attrs)
    end

    test "update_cat_photo/2 with invalid data returns error changeset" do
      cat_photo = cat_photo_fixture()
      assert {:error, %Ecto.Changeset{}} = Photos.update_cat_photo(cat_photo, @invalid_attrs)
      assert cat_photo == Photos.get_cat_photo!(cat_photo.id)
    end

    test "delete_cat_photo/1 deletes the cat_photo" do
      cat_photo = cat_photo_fixture()
      assert {:ok, %CatPhoto{}} = Photos.delete_cat_photo(cat_photo)
      assert_raise Ecto.NoResultsError, fn -> Photos.get_cat_photo!(cat_photo.id) end
    end

    test "change_cat_photo/1 returns a cat_photo changeset" do
      cat_photo = cat_photo_fixture()
      assert %Ecto.Changeset{} = Photos.change_cat_photo(cat_photo)
    end
  end
end

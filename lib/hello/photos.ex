defmodule Hello.Photos do
  @moduledoc """
  The Photos context.
  """

  import Ecto.Query, warn: false

  alias Hello.Repo
  alias Hello.Accounts.User
  alias Hello.Photos.Photo

  @doc """
  Returns the list of photos.

  ## Examples

      iex> list_photos()
      [%Photo{}, ...]

  """
  def list_photos do
    Repo.all(Photo)
  end

  @doc """
  Gets a single photo.

  Raises `Ecto.NoResultsError` if the Photo does not exist.

  ## Examples

      iex> get_photo!(123)
      %Photo{}

      iex> get_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photo!(id), do: Repo.get!(Photo, id)

  @doc """
  Creates a photo.

  ## Examples

      iex> create_photo(%{field: value})
      {:ok, %Photo{}}

      iex> create_photo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_photo(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:photos, attrs)
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo.

  ## Examples

      iex> update_photo(photo, %{field: new_value})
      {:ok, %Photo{}}

      iex> update_photo(photo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a photo.

  ## Examples
      
      iex> delete_photo(photo)
      {:ok, %Photo{}}

      iex> delete_photo(photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_photo(%User{} = user, photo_id) do
    photo = get_photo!(photo_id)

    if user.id == photo.user_id do
      Repo.delete(photo)
      {:ok, photo}
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo changes.

  ## Examples

      iex> change_photo(photo)
      %Ecto.Changeset{data: %Photo{}}

  """
  def change_photo(%Photo{} = photo, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end

  alias Hello.Photos.CatPhoto

  @doc """
  Returns the list of cat_photos.

  ## Examples

      iex> list_cat_photos()
      [%CatPhoto{}, ...]

  """
  def list_cat_photos do
    Repo.all(CatPhoto)
  end

  @doc """
  Gets a single cat_photo.

  Raises `Ecto.NoResultsError` if the Cat photo does not exist.

  ## Examples

      iex> get_cat_photo!(123)
      %CatPhoto{}

      iex> get_cat_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cat_photo!(id), do: Repo.get!(CatPhoto, id)

  @doc """
  Creates a cat_photo.

  ## Examples

      iex> create_cat_photo(%{field: value})
      {:ok, %CatPhoto{}}

      iex> create_cat_photo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cat_photo(attrs \\ %{}) do
    %CatPhoto{}
    |> CatPhoto.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cat_photo.

  ## Examples

      iex> update_cat_photo(cat_photo, %{field: new_value})
      {:ok, %CatPhoto{}}

      iex> update_cat_photo(cat_photo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cat_photo(%CatPhoto{} = cat_photo, attrs) do
    cat_photo
    |> CatPhoto.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cat_photo.

  ## Examples

      iex> delete_cat_photo(cat_photo)
      {:ok, %CatPhoto{}}

      iex> delete_cat_photo(cat_photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cat_photo(%CatPhoto{} = cat_photo) do
    Repo.delete(cat_photo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cat_photo changes.

  ## Examples

      iex> change_cat_photo(cat_photo)
      %Ecto.Changeset{data: %CatPhoto{}}

  """
  def change_cat_photo(%CatPhoto{} = cat_photo, attrs \\ %{}) do
    CatPhoto.changeset(cat_photo, attrs)
  end
end

defmodule Hello.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :title, :string
      add :description, :text
      add :image, :string

      timestamps(type: :utc_datetime)
    end
  end
end

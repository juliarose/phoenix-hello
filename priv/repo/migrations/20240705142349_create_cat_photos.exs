defmodule Hello.Repo.Migrations.CreateCatPhotos do
  use Ecto.Migration

  def change do
    create table(:cat_photos) do
      add :cat_id, references(:cats, on_delete: :delete_all)
      add :photo_id, references(:photos, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:cat_photos, [:cat_id])
    create index(:cat_photos, [:photo_id])
  end
end

defmodule Hello.Repo.Migrations.CreateCats do
  use Ecto.Migration

  def change do
    create table(:cats) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end

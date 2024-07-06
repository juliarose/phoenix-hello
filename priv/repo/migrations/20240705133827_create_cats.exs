defmodule Hello.Repo.Migrations.CreateCats do
  use Ecto.Migration

  def change do
    create table(:cats) do
      add :name, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:cats, [:user_id])
  end
end

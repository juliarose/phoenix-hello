defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :number_of_pets, :integer

    has_one :avatar, Hello.Cat
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :number_of_pets])
    |> validate_required([:name, :number_of_pets])
    |> validate_length(:name, min: 2)
  end
end

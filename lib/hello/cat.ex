defmodule Hello.Cat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cats" do
    field :name, :string

    belongs_to :user, Hello.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cat, attrs) do
    cat
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

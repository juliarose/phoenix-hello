defmodule Hello.Cats.Cat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cats" do
    field :name, :string
    belongs_to :user, Hello.Accounts.User

    timestamps(type: :utc_datetime)
  end
  
  @doc false
  def changeset(cat, attrs) do
    cat
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end

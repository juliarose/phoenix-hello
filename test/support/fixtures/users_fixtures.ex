defmodule Hello.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        number_of_pets: 42
      })
      |> Hello.Users.create_user()

    user
  end
end

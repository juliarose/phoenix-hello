defmodule Hello.CatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hello.Cats` context.
  """

  @doc """
  Generate a cat.
  """
  def cat_fixture(attrs \\ %{}) do
    {:ok, cat} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Hello.Cats.create_cat()

    cat
  end
end

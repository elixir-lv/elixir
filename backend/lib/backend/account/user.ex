defmodule Backend.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :naive_datetime, usec: false]
  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:surname, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :surname, :email])
    |> validate_required([:name, :surname, :email])
  end
end

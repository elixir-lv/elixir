defmodule ElixirBackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    drop_if_exists table("users")

    create table(:users) do
      add :name, :string
      add :surname, :string

      timestamps()
    end

  end
end

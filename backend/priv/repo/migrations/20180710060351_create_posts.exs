defmodule ElixirBackend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :user_id, :integer

      timestamps()
    end

  end
end

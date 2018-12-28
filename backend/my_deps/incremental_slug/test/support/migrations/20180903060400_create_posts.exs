defmodule Backend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def up do
    create table(:posts) do
      add :title, :string, size: 50, null: true
      add :slug, :string, size: 50, null: true
    end
  end

  def down do
		"DROP TABLE posts" |> execute
  end
end

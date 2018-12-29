defmodule Backend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def up do
    create table(:test_posts) do
      add(:title, :string, size: 50, null: true)
      add(:slug, :string, size: 50, null: true)
    end
  end

  def down do
    "DROP TABLE test_posts" |> execute
  end
end

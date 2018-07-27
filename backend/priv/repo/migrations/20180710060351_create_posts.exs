defmodule ElixirBackend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def up do

    "CREATE TABLE IF NOT EXISTS `posts` (
      `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
      `title` VARCHAR(50) NOT NULL,
      `user_id` INT(11) UNSIGNED NULL DEFAULT NULL,
      `inserted_at` DATETIME NULL DEFAULT NULL,
      `updated_at` DATETIME NULL DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=INNODB DEFAULT CHARACTER SET=UTF8;
    "
    |> execute
  end

  def down do
    "DROP TABLE `posts`;" |> execute
  end
end

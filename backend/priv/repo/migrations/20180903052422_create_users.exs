defmodule Backend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do

    "CREATE TABLE IF NOT EXISTS `users` (
      `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(50) NOT NULL,
      `surname` VARCHAR(50) NOT NULL,
      `email` VARCHAR(100) NOT NULL,
      `inserted_at` DATETIME NULL DEFAULT NULL,
      `updated_at` DATETIME NULL DEFAULT NULL,
      UNIQUE INDEX `email` (`email`),
      PRIMARY KEY (`id`)
    ) ENGINE=INNODB DEFAULT CHARACTER SET=UTF8;
    "
    |> execute
  end

  def down do
    "DROP TABLE `users`;" |> execute
  end
end

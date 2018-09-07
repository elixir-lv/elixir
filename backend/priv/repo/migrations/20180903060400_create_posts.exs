defmodule Backend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

	def up do
		"CREATE TABLE IF NOT EXISTS `posts` (
			`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
			`title` VARCHAR(250) NOT NULL,
			`uri` VARCHAR(250) NOT NULL,
			`img` VARCHAR(250) NULL,
			`rating` ENUM('', '1', '2' ,'3' ,'4', '5') DEFAULT '',
			`text` VARCHAR(2000) NULL DEFAULT NULL,
			`inserted_at` DATETIME NULL DEFAULT NULL,
			`updated_at` DATETIME NULL DEFAULT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=INNODB DEFAULT CHARACTER SET=UTF8;"
    |> execute
  end

  def down do
		"DROP TABLE `posts`" |> execute
  end
end

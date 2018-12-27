defmodule Backend.Repo.Migrations.CreatePosts do
  use Ecto.Migration

	def up do
		"CREATE TABLE IF NOT EXISTS `posts` (
			`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
			`title` VARCHAR(250) NOT NULL,
			`slug` VARCHAR(250) NOT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=INNODB DEFAULT CHARACTER SET=UTF8;"
    |> execute
  end

  def down do
		"DROP TABLE `posts`" |> execute
  end
end

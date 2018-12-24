defmodule Backend.Repo.Migrations.CreateBlogCategory do
  use Ecto.Migration

  def up do
  "CREATE TABLE IF NOT EXISTS `blog_category` (
			`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
			`title` VARCHAR(250) NOT NULL,
			`slug` VARCHAR(250) NOT NULL,
			`img` VARCHAR(250) NULL,
			`rating` TINYINT(1) DEFAULT 0 NOT NULL,
			`text` VARCHAR(2000) NULL DEFAULT NULL,
			`inserted_at` DATETIME NULL DEFAULT NULL,
			`updated_at` DATETIME NULL DEFAULT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=INNODB DEFAULT CHARACTER SET=UTF8;"
    |> execute
  end

  def down do
		"DROP TABLE `blog_category`" |> execute
  end
end

# DB

## Params

* username: "root",
* password: "FILL_THIS",
* database: "elixir",
* hostname: "172.60.1.13",

## Log into the container

```shell
docker exec -it elixir-mysql bash
```

## Log into the mysql service

```shell
mysql -uroot -p
```
## Create a DB

```sql
CREATE DATABASE `elixir`;
```
## Create tables

```sql
USE `elixir`;

CREATE TABLE `user`(
    `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'MAX 65535 records',
    `name` VARCHAR(250) NOT NULL,
    `surname` VARCHAR(250) NOT NULL,
    PRIMARY KEY(`id`)
) ENGINE = INNODB DEFAULT CHARACTER SET = UTF8;

INSERT INTO `user` (`name`, `surname`) VALUES('John', 'Doe'),('Jane', 'Doe');

SELECT * FROM `user`;

CREATE TABLE `post`(
    `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'MAX 65535 records',
    `title` VARCHAR(250) NOT NULL,
    `user_id` SMALLINT UNSIGNED NULL DEFAULT NULL COMMENT 'Author who created this post.',
    PRIMARY KEY(`id`)
) ENGINE = INNODB DEFAULT CHARACTER SET = UTF8;

INSERT INTO `post` (`title`, `user_id`) VALUES('post A', 1),('post B', 1);

SELECT * FROM `post`;
```

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
## Create posts

```sql
USE `elixir`;

CREATE TABLE `post`(
    `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'MAX 65535 records',
    `title` VARCHAR(250) NOT NULL,
    PRIMARY KEY(`id`)
) ENGINE = INNODB DEFAULT CHARACTER SET = UTF8;

INSERT INTO `post` (`title`) VALUES('post A'),('post B');

SELECT * FROM `post`;
```

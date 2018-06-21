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


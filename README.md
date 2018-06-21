# elixir

Test project so I could learn Elixir / Phoenix.

## Add to hosts

### Open the local hosts

```shell
sudo nano /etc/hosts
```

### Add this

```
172.60.1.10     elixir.local
172.60.1.11     api.elixir.local
```

## Setup front-end, back-end, testing environment with Docker

### Configure

#### Copy the envirnoment example file

```shell
cp .env.example .env
```

#### Set values

Replace every 'FILL_THIS' word with a required value.

### Start-up the projects

In this project directory execute

```shell
docker-compose up
```

## Open

* [elixir.local](http://elixir.local)
* [api.elixir.local:4000](http://api.elixir.local:4000/)
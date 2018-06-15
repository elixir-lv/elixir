# elixir

Test project so I could learn Elixir / Phoenix.

## Add to hosts

```shell
nano /etc/hosts
```

```
172.17.0.1      elixir.local api.elixir.local
```

## Setup front-end, back-end, testing environment with Docker

### Configure

### Copy the envirnoment example file

```shell
cp .env.example .env
```

### Set values

Replace every 'FILL_THIS' word with a required value.

### Start-up the projects

In this project directory execute

```shell
docker-compose up
```
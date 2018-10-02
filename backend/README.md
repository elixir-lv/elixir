# ElixirBackend

## Project was created with

```shell
mix phx.new elixir_backend --no-brunch --no-html --database mysql
```

## First steps

* Config DB settings.
* Create the DB -  `mix ecto.create`
* Generate Users' related code - `mix phx.gen.json Account User users name:string surname:string`
* Generate Posts' related code - `mix phx.gen.json Blog Post posts title:string user_id:integer`

## Tests

```shell
docker exec -it elxiir-frontend bash
MIX_ENV=test mix.test
```

## TODO

* Add here the link to dev/Elixir/Phoenix/Setup-API.
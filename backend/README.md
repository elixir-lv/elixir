# ElixirBackend

## Project was created with

```shell
mix phx.new elixir_backend --no-brunch --no-html --database mysql
```

## First steps

* Config DB settings.
* Create the DB -  `mix ecto.create`
* Generate Users' related code - `mix phx.gen.json Users User users name:string surname:string`
* Generate Posts' related code - `mix phx.gen.json Blog Post posts title:string user_id:integer`

-------------------

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

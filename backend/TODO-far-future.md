## Tests

* Is is it possible to re-gen auto-gen tests?
* How to tests lists, like posts?

## Other

* Add *.secret examples.x
* Handle [ENUMs as Integers](https://stackoverflow.com/a/113648) because it is better indexed for a fixed (and small) amount of integers.
Currently have problems returning values that are strings, but defined as :integer. Saving is fine.

# Far future TODO

## Add integration with different storate engines

### Resources

* [Store Everything With Elixir and Mnesia](https://code.tutsplus.com/articles/store-everything-with-elixir-and-mnesia--cms-29821)

### List 

* Postgres.
* mongo.
* ETS (Erlang Term Storage) cache.
* Disk-based ETS (DETS), which provide slightly more limited functionality, but allow you to save your contents to a file.
* [Erlang mnesia](http://erlang.org/doc/man/mnesia.html#create_table-2)
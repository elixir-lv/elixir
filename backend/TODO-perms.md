# Add perm processing

* bundle components. Allow bundle inside a bundle inside a bundle.
* strenght that allows to overwrite another components.
* Combine perms from organization, products, earned loyality products.

## Outcome would look like this

```json
{
  posts: {global: {view: true, edit: false}, types: {dogs: {view: true, edit: true}}},
  contacts: {global: {view: true, edit: false}, parts: {email: {send: true, view: true}}
}
```
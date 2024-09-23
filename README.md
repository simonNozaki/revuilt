# Revuilt

> Vue.js 2 filter syntax converter

Revuilt is a CLI tool for chunk converting Vue filter syntax to a function call one.

Some templates on Vue.js 2 have Vue filter syntax like this:

```vue
{{ startAt | date }}
```

For migrating Vue app to Vue.js 3, all Vue filters should be deprecated. Revuilt convert those to a function call.

```vue
{{ $date(startAt) }}
```

> [!NOTE]
> A vue app must have an alternative of Vue filter, in other words Revuilt does not generate functions to replace.
> For instance, Revuilt assumes that a Vue app already implements `$date` function in the example above.  

## Usage

```bash
./bin/revuilt -d examples/ -f price -s '$price'
```

### options:

| # | option name                 | required | description                                                              |
|---|-----------------------------|----------|--------------------------------------------------------------------------|
| 1 | -d / --dir                  | true     | Converting target  root directory. CLI search filter syntax recursively. |
| 2 | -f / --filter-name          | true     | Vue filter name to replace function call                                 |
| 3 | -s / --function--symbol     | true     | Function symbol that is alternative to Vue filter                        |
| 4 | -t / --only-write-temporary | false    | Revuilt does not swap with new file when this flag in on.                |

## Development
### Prerequisite

- ruby: 3.3.0

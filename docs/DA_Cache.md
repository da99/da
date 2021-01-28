
DA::Cache (Crystal):
======

```crystal
  cache = DA::Cache.new("my_prefix")
  cache.write("my_key", "my value")

  cache = DA::Cache.new("my_prefix")
  cache.read("my_key")
  cache.delete("my_key")
```

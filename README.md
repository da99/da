
Reference:
============

```crystal
  DA.print_help
  DA.print_help substring_search
```

Cache:
======

```crystal
  cache = DA::Cache.new("my_prefix")
  cache.write("my_key", "my value")

  cache = DA::Cache.new("my_prefix")
  cache.read("my_key")
  cache.delete("my_key")
```


Process:
=======

```crystal
  DA.exit!(Int32, String)
  DA.exit!(String)

  DA.system!(cmd)  # Prints output of cmd.
  DA.success!(cmd) # Prints output of cmd only on failure and exits.
  DA.run(cmd)      # Shows which command is running and returns status.
```

Links:
======

* Entre: Alternative to inotify. Reload servers and browers
  on file changes: http://entrproject.org


Reference & Intro:
==================

```zsh
  da_dev compile file.name.ext

  da_dev watch
  da_dev watch reload

  da_dev watch run-file myfile.1.txt
  da_dev watch run-file myfile.2.txt

  da_dev watch proc sleep 10

  da_dev watch run-last-file

  da_dev watch run my_cmd with -args
  da_dev watch run __ with -args
```

For `watch` files:

```zsh
  reset
  clear
  bin compile
  run my process
  proc my long running process
  # bin compile
  PING
```

Postgresql Development:
=======================

The following are for development purposes only.

```sh
  sudo -u postgres psql -U postgres
  sudo -u postgres createuser $USER \
    --connection-limit=3      \
    --no-createdb             \
    --no-createrole           \
    --no-superuser            \
    --encrypted               \
    --login

  sudo -u postgres createdb  --owner=$USER my_db_name

```


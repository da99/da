# da\_deploy

```
install gc libevent
/deploy/apps
  /my\_app
    date-sha1
      - sv/run
      - sv/log/run
```

Deploy watch service:
  - Every 5 seconds
    get latest release.
    "down" previous release services.
    link to new release.
  - Service da\_deploy has to be manually restarted on the server:
    da_deploy service install da_deploy
  - SSH into server and run "da\_deploy service install name of service".
    Fully automated deploys are hard in case anything goes wrong.


# dockerhub-check-rate-limit

Container to output your current _anonymous_/unauthenticated DockerHub image pull ratelimit stats.

Works equally well when run locally, or on that Kubernetes cluster with the rate limiting issue.

```
Usage: ratecheck [MODE]

 --all         Output all available data, with titles, one per line
 --current     Pulls consumed in the current period (limit minus remaining)
 --help        Outputs this text
 --limit       Maximum pulls allowed in the current period
 --interval    Length of a rate limiting period in seconds
 --pretty      Outputs some info prettily-formated. Default if no other option is specified.
 --remaining   Pulls remaining in the period
```

## Running from DockerHub

Hopefully you haven't already hit the rate limit in this period:

```shell
docker run electricwarr/dockerhub-check-rate-limit [MODE]
```

## Building and Running a Local Copy

- `./build.sh` is a shortcut to quickly build a local copy of the image
- `./run.sh` runs your local copy - you can pass MODE parameters to this script if you like
- `./debug.sh` drops you into a shell in the latest local version of the image, mounting a copy of the script for convenience. Designed to streamline development - you can run the script manually with `./ratecheck.sh`, make changes in your usual editor, then run it again to see the results instantly.

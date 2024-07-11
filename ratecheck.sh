#! /bin/ash
# shellcheck shell=busybox
# ^ This hides some but not all "Nyah nyah nyah nyah nyah not if you're using daa-aash" errors

usage='Usage: ratecheck [MODE]

 --all         Output all available data, with titles, one per line
 --current     Pulls consumed in the current period (limit minus remaining)
 --help        Outputs this text
 --limit       Maximum pulls allowed in the current period
 --interval    Length of a rate limiting period in seconds
 --pretty      Outputs some info prettily-formated. Default if no other option is specified.
 --remaining   Pulls remaining in the period
'

if [[ $# == 0 ]]; then
  mode="pretty"
elif [[ $# -gt 1 ]]; then
  echo 'ERROR: specify a single mode only'
  echo "$usage"
  exit 1
else
  mode="${1#--}"
  case $mode in
    help)
      echo "$usage"
      exit 0
      ;;
    all)
      ;;
    current)
      ;;
    limit)
      ;;
    interval)
      ;;
    pretty)
      ;;
    remaining)
      ;;
    *)
      echo "ERROR: unrecognised mode '$1'"
      echo && echo "$usage"
      exit 1
      ;;
    esac
fi

# Get an anonymous authentication token from Docker
token="$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)"

# Get rate limit and interval for this token
jwt_payload_params="$(jwt decode --json "$token" | jq '.payload.access[0].parameters')"
rate_limit_user="$(echo "$jwt_payload_params" | jq -r '.pull_limit')"
rate_interval="$(echo "$jwt_payload_params" | jq -r '.pull_limit_interval')"

# Make a "HEAD" request for "ratelimitpreview/test", which returns our rate limit stats without consuming a "pull"
#  This is a real image! https://hub.docker.com/r/ratelimitpreview/test
#  Buuut testing revealed that requesting a non-existent image works just as well :(
ratelimitpreview_headers="$(curl -s --head --header  "Authorization: Bearer $token" 'https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest' | grep -E 'ratelimit-limit|ratelimit-remaining' | sed 's/;w.*//' | awk '{print $2}')"
# Insane shell gymnastics to extract two values to separate variables in one command
IFS=$'\n' read -rd '' rate_limit_request rate_remaining < <(echo "$ratelimitpreview_headers")

# Warn if the two limits differ, we're going to assume the most recent is always right
if [[ $rate_limit_user -ne $rate_limit_request ]]; then
  echo "WARNING: Token ($rate_limit_user) and test request ($rate_limit_request) limits differ. Please kindly inform the developer: 'You were wrong'."
fi
rate_limit="$rate_limit_request"

rate_current=$(( rate_limit - rate_remaining ))

case $mode in
  all)
    # WARNING: The following heredoc must indented with TABS in order to remain PRETTY
    cat - <<- EOF
		Remaining: $rate_remaining
		Current: $rate_current
		Limit: $rate_limit
		Interval: $rate_interval
		EOF
    ;;
  current)
    echo "$rate_current"
    ;;
  limit)
    echo "$rate_limit"
    ;;
  interval)
    echo "$rate_interval"
    ;;
  pretty)
    echo "$rate_remaining/$rate_limit pulls remaining ($rate_current used)"
    ;;
  remaining)
    echo "$rate_remaining"
    ;;
esac

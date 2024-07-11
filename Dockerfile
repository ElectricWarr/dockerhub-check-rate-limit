FROM alpine:3.19
RUN apk --no-cache update \
 && apk add curl jq \
 && apk add jwt-cli --repository='http://dl-cdn.alpinelinux.org/alpine/edge/testing/'
COPY ratecheck.sh .
ENTRYPOINT ["/ratecheck.sh"]

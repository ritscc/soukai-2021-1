FROM paperist/alpine-texlive-ja

RUN apk add bash git jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

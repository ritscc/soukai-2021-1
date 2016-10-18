#!/bin/bash

url=$(git remote -v | sed -n -e "1s/^origin\s\+//g; 1s/https:\/\/x-token-auth:{access_token}/git/g; 1s/\:/\//g; 1s/^git@/https:\/\//g; 1s/\.git.\+$//g; 1p;")
comment=$(git log -1 --date=iso --pretty="format:%ad : %s \"$url/commits/%H\"")

curl -F file=@build/document.pdf \
    -F initial_comment="$comment" \
    -F channels=#soukai \
    -F token=$SLACK_TOKEN https://slack.com/api/files.upload | grep -v "\"ok\":false"


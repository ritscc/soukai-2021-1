#!/bin/bash
set -eux

# Run auto input script
tools/auto_input.sh

# Build document.pdf
platex document
ptex2pdf -interaction=nonstopmode -l -ot -kanji=utf8 -synctex=1 document.tex

#  Release generated PDF (only PR targeat develop or master)
# -----------------------------------------------------------
#   https://qiita.com/denkiuo604/items/137a1b3fc1955cfb9c58

if [ $GITHUB_BASE_REF = "master" -o $GITHUB_BASE_REF = "main" ]; then
  # create release
  res=`curl -H "Authorization: token $GITHUB_TOKEN" \
  -X POST https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
  -d "
  {
    \"tag_name\": \"ver.$GITHUB_RUN_NUMBER\",
    \"target_commitish\": \"$GITHUB_SHA\",
    \"name\": \"ver.$GITHUB_RUN_NUMBER\",
    \"draft\": false,
    \"prerelease\": true
  }"`

  # Extract release id
  rel_id=`echo ${res} | jq '.id'`

  # Upload built document.pdf
  curl -H "Authorization: token $GITHUB_TOKEN" \
    -X POST https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/${rel_id}/assets?name=document.pdf \
    --header 'Content-Type: application/pdf' \
    --upload-file document.pdf
fi

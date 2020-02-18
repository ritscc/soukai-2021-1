#!/bin/bash
# - written by @aonrjp

MODULES=('constitution' 'tex-commands')
HTTPS_HOST='https://gitlab.com'

# CI実行の場合はCI_JOB_TOKENを利用して取ってくる
if [ -v CI_JOB_TOKEN ]; then
    HTTPS_HOST="https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com"
fi

for module in ${MODULES[@]}
do
    git clone ${HTTPS_HOST}/ritscc/soukai/${module}.git
done


#/bin/bash

# get bitbucket token
token="$(curl -s https://bitbucket.org/site/oauth2/access_token \
    -d grant_type=client_credentials \
    -u $CLIENT_ID:$CLIENT_SECRET | \
    awk -F',' '/"access_token"/{print $1}' | awk -F':' '{print $2}' | sed s/[\ \"]//g)"

if [ -z $token ]; then
    echo "failed to get token"
    exit 1
fi

# save to ~/.netrc
cat <<EOS > ~/.netrc
machine bitbucket.org
login x-token-auth
password $token
EOS

# fix url to https
mv .gitmodules{,.org}
cat .gitmodules.org | sed s/:/\\// | sed s/git@/https:\\/\\// > .gitmodules

# install submodule
git submodule update --init --recursive

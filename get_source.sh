#!/bin/sh
git clone ssh://git@bitbucket.org/ritscc/constitution

git fetch origin
git merge HEAD FETCH_HEAD

cd constitution; git fetch origin; git merge HEAD FETCH_HEAD


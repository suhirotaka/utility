#!/bin/bash

FLAG_MSG='__DEPLOY_TO_PRODUCTION__'

cd .
prev_deploy=$(git log --grep $FLAG_MSG --pretty=format:"%H" | head -1)
included_prs=$(git log ${prev_deploy}..HEAD --oneline | grep "Merge pull request" | grep -o -E "#[0-9]+")
git commit --allow-empty -m $FLAG_MSG -m "included PRs:" -m "${included_prs}"

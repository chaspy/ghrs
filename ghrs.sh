#!/bin/bash
# This script is ghrs implemented by bash for testing

json2md() {
  echo -e "\n### $1" >> $RESULT
  while read LINE; do
    title=$(echo $LINE | jq -r .title)
    url=$(echo $LINE | jq -r .url)
    assignee=$(echo $LINE | jq -r .assignee)
    echo "[$title]($url) by @$assignee" >> $RESULT
  done < $1-$2.json
}

get_issues() {
  if [[ $1 == issues ]]; then
    optional_query="&labels=${LABEL}"
    asn='.assignee.login'
    REPOS=$ISSUE_REPOS
  else
    optional_query=""
    asn='.user.login'
    REPOS=$PR_REPOS
  fi
  for REPO in $REPOS; do
    curl -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/quipper/${REPO}/${1}?since=${SINCE}${optional_query}" | \
    jq -cr '.[] | {title: .title , url: .url , assignee: '$asn'}' > $REPO-$1.json
    json2md $REPO $1
  done
}

main() {
  . config.sh
  echo "# Retrospective our activities since $SINCE" > $RESULT

  for type in issues pulls; do
    echo -e "\n## ${type}" >> $RESULT
    get_issues $type
  done

  rm -f *.json
}

main

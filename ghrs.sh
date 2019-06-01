#!/bin/bash
# This script is ghrs implemented by bash for testing

get_issues() {
  if [[ $1 == issues ]]; then
    optional_query="&labels=${LABEL}"
    asn='.assignee.login'
    REPOS=$ISSUE_REPOS
  else
    optional_query="&state=closed"
    asn='.user.login'
    REPOS=$PR_REPOS
  fi
  for REPO in $REPOS; do
    echo -e "\n### ${REPO}" >> $RESULT

    # Get last page
    uri="https://api.github.com/repos/quipper/${REPO}/${1}"
    query="?since=${SINCE}${optional_query}&per_page=100"
    last_page=$(curl --silent --head -H "Authorization: token $GITHUB_TOKEN" "${uri}${query}" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g')

    if [ -z "$last_page" ]; then
      curl --silent -H "Authorization: token $GITHUB_TOKEN" "${uri}${query}" | \
      jq -cr ".[] | {title: .title , url: .html_url , assignee: ${asn} , updated_at: .updated_at}" | \
      jq ". |select( .assignee !=null) |select( .assignee | inside(\"${MEMBERS}\"))" | \
      jq ". |select(.updated_at > \"${SINCE}\")" | \
      jq -r '"- [\(.title)](\(.url)) by @\(.assignee) at \(.updated_at)"' >> $RESULT
    else
      for p in `seq 1 $last_page`; do
        curl --silent -H "Authorization: token $GITHUB_TOKEN" "${uri}${query}&page=$p" | \
        jq -cr ".[] | {title: .title , url: .html_url , assignee: ${asn} , updated_at: .updated_at}" | \
        jq ". |select( .assignee !=null) |select( .assignee | inside(\"${MEMBERS}\"))" | \
        jq ". |select(.updated_at > \"${SINCE}\")" | \
        jq -r '"- [\(.title)](\(.url)) by @\(.assignee) at \(.updated_at)"' >> $RESULT
      done
    fi
  done
}

main() {
  . config.sh
  echo "# Retrospective our activities since $SINCE" > $RESULT

  for type in issues pulls; do
    echo -e "\n## ${type}" >> $RESULT
    get_issues $type
  done

  ## TODO remove release PR

  rm -f *.json
}

main

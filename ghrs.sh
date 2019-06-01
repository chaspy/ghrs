#!/bin/bash
# This script is ghrs implemented by bash for testing

call_api_and_write_result() {
  query_result=$(curl --silent -H "Authorization: token $GITHUB_TOKEN" "${1}" | \
  jq -cr ".[] | {title: .title , url: .html_url , assignee: ${asn} , updated_at: .updated_at}" | \
  jq ". |select( .assignee !=null) |select( .assignee | inside(\"${MEMBERS}\"))" | \
  jq ". |select(.title | contains(\""${EXCEPT_WORD}"\") | not)" | \
  jq ". |select(.updated_at > \"${SINCE}\")" | \
  jq -r '"- [\(.title)](\(.url)) by @\(.assignee) at \(.updated_at)"')

  if [ -n "$query_result" ]; then
    echo -e "${query_result}" >> $RESULT
  else
    return 1
  fi
}

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
    uri="https://api.github.com/repos/${OWNER}/${REPO}/${1}"
    query="?since=${SINCE}${optional_query}&per_page=100"
    last_page=$(curl --silent --head -H "Authorization: token $GITHUB_TOKEN" "${uri}${query}" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g')

    if [ -z "$last_page" ]; then
      call_api_and_write_result "${uri}${query}"
    else
      for p in `seq 1 $last_page`; do
        call_api_and_write_result "${uri}${query}&page=$p"
        if [[ $? -ne 0 ]]; then
          break
        fi
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

  rm -f *.json
}

main

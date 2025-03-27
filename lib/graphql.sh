#!/bin/bash
set -euo pipefail

get_latest_build_state() {
  local org="$1"
  local pipeline="$2"
  local branch="$3"
  local token="$4"

  local query=$(cat <<EOF
{
  pipeline(slug: "$org/$pipeline") {
    builds(first: 1, branch: "$branch") {
      edges {
        node {
          state
        }
      }
    }
  }
}
EOF
)

  local response=$(curl -sS -X POST https://graphql.buildkite.com/v1 \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"$query\"}")

  echo "$response" | jq -r '.data.pipeline.builds.edges[0].node.state'
}

get_last_commit_from_buildkite() {
  local org="$1"
  local pipeline="$2"
  local branch="$3"
  local state="$4"
  local token="$5"

  local state_filter=""
  if [[ -n "$state" ]]; then
    state_filter="state: $state,"
  fi

  local query=$(cat <<EOF
{
  pipeline(slug: "$org/$pipeline") {
    builds(first: 1, branch: "$branch", $state_filter) {
      edges {
        node {
          commit
          branch
          state
        }
      }
    }
  }
}
EOF
)

  local response=$(curl -sS -X POST https://graphql.buildkite.com/v1 \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"$query\"}")

  echo "$response" | jq -r '.data.pipeline.builds.edges[0].node.commit'
}

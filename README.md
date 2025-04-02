# Last Successful Commits Buildkite Plugin

This Buildkite plugin compares the current commit with the last known successful (or user-specified state) commit on a specified branch. It generates a changelog and optionally includes a list of changed files or full git diffs.

## What it does

- Compares the current commit (`HEAD`) to the last commit from a matching build (based on branch and state).
- If there are no new commits, the build is skipped by uploading an empty pipeline.
- If there are new commits, a changelog is generated and annotated on the build.
- Optionally shows file-level diffs or full `git diff` output.

## Configuration

| Name | Type | Required | Default | Description |
|-------------------------|----------|----------|---------|-------------|
| `organization` | string | Yes | - | Buildkite organization slug |
| `pipeline` | string | Yes | - | Buildkite pipeline slug |
| `branch` | string | No | `main` | Git branch to compare against |
| `state` | string | No | - | Build state to filter (e.g. `PASSED`, `FAILED`). Defaults to latest non-RUNNING build |
| `from` | string | No | - | Optional commit SHA to compare from (overrides automatic detection) |
| `to` | string | No | `HEAD` | Commit SHA to compare to |
| `fallback-commit-count` | integer | No | `5` | Number of commits to show if no previous build is found |
| `detailed` | boolean | No | `false` | If `true`, shows full `git diff`; otherwise shows only changed file paths |
| `changes_api_token` | string | No | - | Buildkite GraphQL API token (optional – see authentication below) |

## Authentication

To automatically detect the "from" commit, this plugin queries the Buildkite GraphQL API to find the last build matching your `state`, `branch`, and `pipeline`.

You can authenticate in two ways:

### 1. Direct input (recommended)

Pass the API token using preferred retrieval method to the plugin config:

```yaml
changes_api_token: "your-buildkite-api-token"
```

### 2. Buildkite secrets (fallback)

If not provided, the plugin will run:

```
buildkite-agent secret get changes_api_token
```

You can provide this secret using your CI secret manager (e.g., Kubernetes secrets, AWS SSM, Vault).

If neither the changes_api_token nor the from commit is provided, the plugin will fail and exit the build.

## Basic Example

```yaml
steps:
  - label: "Changelog and change detection"
    plugins:
      - rayaprolu/last-successful-commits#v2.3.4:
          organization: "my-org"
          pipeline: "my-pipeline"
```

## Full Example

```yaml
steps:
  - label: "Smart CI skip"
    plugins:
      - rayaprolu/last-successful-commits#v2.3.4:
          organization: "my-org"
          pipeline: "my-pipeline"
          branch: "develop"
          state: "PASSED"
          from: "" ## Commit info if you have it, else skip this to fetch the last commit
          to: ""   ## Commit info if you have it, else skip this to fetch the last commit
          fallback-commit-count: 10
          detailed: true
          changes_api_token: "your-buildkite-api-token"
```

## Output Example

When new commits are found:

```
Commits between:
abc123 → def456

- abc123 Alice: Fix login redirect
- def456 Bob: Refactor sidebar toggle

Changed Files:
M login.js
A sidebar.js
```
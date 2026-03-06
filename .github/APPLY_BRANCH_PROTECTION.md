# Apply branch protection from JSON

GitHub doesn’t have an “upload JSON” button in the UI. Use one of these methods to apply `branch-protection-main.json` to the `main` branch.

## Option 1: GitHub CLI (easiest)

1. Install [GitHub CLI](https://cli.github.com/) and run `gh auth login`.
2. From the repo root, run:

```bash
gh api repos/chavezMac/HoneyComb/branches/main/protection \
  -X PUT \
  --input .github/branch-protection-main.json
```

Done. The `main` branch will require a pull request with 1 approval (from you via CODEOWNERS) and will block force pushes.

## Option 2: curl with a token

1. Create a [Personal Access Token](https://github.com/settings/tokens) with scope `repo`.
2. Run (replace `YOUR_TOKEN` with your token):

```bash
curl -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/chavezMac/HoneyComb/branches/main/protection \
  -d @.github/branch-protection-main.json
```

## What this config does

- **Require a pull request** before merging into `main` (1 approval).
- **Require review from Code Owners** — with `.github/CODEOWNERS` set to `@chavezMac`, your review is required.
- **Block force pushes** to `main`.

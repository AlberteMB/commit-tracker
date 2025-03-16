bash
#!/bin/bash

# Define the path to the commit tracker repository
TRACKER_REPO_PATH="/home/albertemb/Projects/CommitTracker"

# Check if the current branch is not main or if the repo is a fork
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
IS_FORK=$(git remote -v | grep -q "origin.*fork")

# Create the post-commit hook if it doesn't exist
HOOK_PATH=".git/hooks/post-commit"
if [ ! -f "$HOOK_PATH" ]; then
  echo "Creating post-commit hook..."

  cat > "$HOOK_PATH" <<EOF
  #!/bin/sh

  # Extract commit metadata
  COMMIT_HASH=\$(git rev-parse HEAD)
  COMMIT_DATE=\$(git log -1 --format=%cd --date=iso)
  REPO_NAME=\$(basename -s .git \$(git remote get-url origin))
  CURRENT_BRANCH=\$(git rev-parse --abbrev-ref HEAD)

  # Check if current branch is not main or if repo is a fork
  IS_FORK=\$(git remote -v | grep -q "origin.*fork")

  if [ "\$CURRENT_BRANCH" != "main" ] || [ "\$IS_FORK" = "true" ]; then
    # Navigate to the tracking repository
    cd /home/albertemb/Projects/CommitTracker

    # Pull the latest changes to avoid conflicts
    git pull origin main --rebase

    # Append commit data to a log file
    echo "\$COMMIT_DATE | \$REPO_NAME | \$CURRENT_BRANCH | \$COMMIT_HASH" >> commits.log

    # Stage and commit the updated log file
    git add commits.log
    git commit -m "Track commit from \$REPO_NAME on branch \$CURRENT_BRANCH"

    # Push the commit to the tracking repository
    git push origin main

    # Return to the original repository
    cd -
  fi
EOF
 chmod +x "$HOOK_PATH"
 echo "Post-commit hook created successfully."
else
echo "Post-commit hook already exists."
fi

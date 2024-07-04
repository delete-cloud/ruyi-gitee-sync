#!/bin/bash

# Ensure that the necessary environment variables are set
if [[ -z "${your_gitee_username}" || -z "${your_gitee_token}" ]]; then
  echo "Error: Environment variables your_gitee_username and your_gitee_token must be set."
  exit 1
fi

# Get the current username
current_user=$(whoami)

# Define the directory path
directory_path="/home/${current_user}/ruyisdk/ruyi"

# Check if the directory exists, if not, create it
if [[ ! -d "${directory_path}" ]]; then
  mkdir -p "${directory_path}"
  echo "Directory ${directory_path} created."
fi

# Change to the directory
cd "${directory_path}"

# Initialize the git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
  git init
  git remote add origin https://github.com/ruyisdk/ruyi.git
  echo "Initialized empty Git repository and added remote origin."
fi

# Verify if the remote repository is set up correctly
remote_output=$(git remote -v)
expected_output="https://github.com/ruyisdk/ruyi.git"
if echo "$remote_output" | grep -q "$expected_output"; then
  echo "Remote repository is set up correctly."
else
  echo "Error: Remote repository is not set up correctly."
  exit 1
fi

# Fetch the latest changes from the origin repository
git fetch origin

# Check if the 'main' branch exists on the remote and set it as the upstream branch
if git show-ref --verify --quiet refs/remotes/origin/main; then
  git branch --set-upstream-to=origin/main
  echo "Set upstream branch to origin/main."
else
  echo "Error: 'main' branch does not exist on the remote repository."
  exit 1
fi

# Pull the latest changes from the main branch
git pull origin main

# Check out the main branch locally
if git show-ref --verify --quiet refs/heads/main; then
  git checkout main
else
  git checkout -b main
fi

# Fetch the latest changes from Gitee's main branch
git fetch https://$your_gitee_username:$your_gitee_token@gitee.com/$your_gitee_username/packages-index.git main

# Merge Gitee's main branch changes into the local main branch
git merge FETCH_HEAD

# Force push the changes to the Gitee repository main branch
git push -f https://$your_gitee_username:$your_gitee_token@gitee.com/$your_gitee_username/packages-index.git main

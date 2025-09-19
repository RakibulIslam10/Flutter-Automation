#!/bin/bash

# ---------------------------------------
# Auto Git Push Script
# Usage: curl -sL https://raw.githubusercontent.com/username/repo/main/push_my_code.sh | bash
# ---------------------------------------

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Git is not installed. Installing..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install git -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    else
        echo "Unsupported OS. Please install Git manually."
        exit 1
    fi
fi

# Set Git config if not already set
git_user=$(git config --global user.name)
git_email=$(git config --global user.email)

if [ -z "$git_user" ]; then
    read -p "Enter your Git username: " git_user
    git config --global user.name "$git_user"
fi

if [ -z "$git_email" ]; then
    read -p "Enter your Git email: " git_email
    git config --global user.email "$git_email"
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    echo "Initialized empty Git repository."
fi

# Check for remote origin
remote=$(git remote get-url origin 2>/dev/null)
if [ -z "$remote" ]; then
    read -p "Enter GitHub repo name (will create https://github.com/$git_user/REPO.git): " repo_name
    git remote add origin "https://github.com/$git_user/$repo_name.git"
    
    # Create the repo on GitHub using GitHub CLI if installed
    if command -v gh &> /dev/null; then
        gh repo create "$repo_name" --public --source=. --remote=origin --push
    else
        echo "GitHub CLI not installed. Make sure you create repo $repo_name manually if it doesn't exist."
    fi
fi

# Add, commit, push
git add .
git commit -m "Auto push from script" 2>/dev/null
git push -u origin main 2>/dev/null || git push -u origin master

echo "✅ Code pushed successfully!"

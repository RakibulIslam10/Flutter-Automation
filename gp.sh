#!/bin/bash

# ---------------------------------------
# Auto Git Push Script
# Usage: Save as push_my_code.sh and run:
# bash push_my_code.sh
# ---------------------------------------

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Git is not installed. Installing..."
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
    read -p "Remote not found. Enter your GitHub repo name (already created on GitHub): " repo_name
    git remote add origin "https://github.com/$git_user/$repo_name.git"
    echo "Added remote origin https://github.com/$git_user/$repo_name.git"
fi

# Add, commit, push
git add .
# commit only if there are changes
if ! git diff-index --quiet HEAD --; then
    git commit -m "Auto push from script"
fi

# Determine branch (main or master)
branch=$(git branch --show-current)
if [ -z "$branch" ]; then
    branch="main"
    git branch -M $branch
fi

git push -u origin $branch

echo "✅ Code pushed successfully!"

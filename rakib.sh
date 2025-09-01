#!/usr/bin/env bash

case "$1" in

"generate-views")
    # shellcheck disable=SC2162
    read -p "📥 Enter View Names (space-separated): " viewNames
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/vv.sh | bash -s $viewNames
    ;;

"generate-widget")
    # shellcheck disable=SC2162
    read -p "Enter View Name: " viewName
    # shellcheck disable=SC2162
    read -p "📥 Enter Widget Names (space-separated): " widgetNames
    IFS=' ' read -r -a widgetArray <<< "$widgetNames"
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/widt.sh | bash -s "$viewName" "${widgetArray[@]}"
    ;;

"create-structure")
    echo "🛠️ Creating Flutter project folder structure..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/cs.sh | bash
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/cu.sh | bash
#    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/py.sh | bash
    ;;

"generate-api-method")
    echo "🛠️ Creating Api Method..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/am.sh | bash
    ;;


"generate-clean-yaml")
    # 📥 Ask user for project name and description
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Name: " projectName
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Description: " projectDescription

    # 🔗 Call remote script with projectName and description as arguments
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/ml.sh | bash -s "$projectName" "$projectDescription"
    ;;

#"get-dependencies")
#    echo "🔽 Downloading & applying dependencies..."
#    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/py.sh | bash
#    ;;

"setup-firebase")
    echo "📥 Downloading Firebase setup script..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/frbs.sh -o frbs.sh
    chmod +x frbs.sh
    echo "🚀 Running Firebase setup..."
    ./frbs.sh
    ;;
  
  
  "create-shaKey")
      echo "🛠️ Creating SHA Key..."
      curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/sa.sh | bash
      ;;


esac

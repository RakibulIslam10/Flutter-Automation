#!/usr/bin/env bash

case "$1" in

"generate-views")
    # shellcheck disable=SC2162
    read -p "📥 Enter View Names (space-separated): " viewNames
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/refs/heads/main/view.sh | bash -s $viewNames
    ;;

"generate-widget")
    # shellcheck disable=SC2162
    read -p "Enter View Name: " viewName
    # shellcheck disable=SC2162
    read -p "📥 Enter View Names (space-separated): " widgetNames
    IFS=' ' read -r -a widgetArray <<< "$widgetNames"
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/main/widget | bash -s "$viewName" "${widgetArray[@]}"
    ;;

"create-structure")
    echo "🛠️ Creating Flutter project folder structure..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/refs/heads/main/stucture.sh | bash
    ;;
"generate-api-method")
    echo "🛠️ Creating Api Method..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/refs/heads/main/api_method.sh | bash
    ;;

"get-dependencies")
    echo "🔽 Downloading & applying dependencies..."
    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Structure-Auto/refs/heads/main/get_dependencies.sh | bash
    ;;


*)
    echo "❌ Unknown command: $1"
    echo "👉 Available commands:"
    echo "   generate-views"
    echo "   generate-widget"
    echo "   create-structure"
    ;;
esac

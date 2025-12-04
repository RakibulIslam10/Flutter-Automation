#!/usr/bin/env bash

case "$1" in






"make-str")
    echo "🛠️ Creating Flutter project folder structure..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/cs.sh | bash
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/cu.sh | bash
    # curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/py.sh | bash
    ;;
"make-views")
    # shellcheck disable=SC2162
    read -p "📥 Enter View Names (space-separated): " viewNames
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/vv.sh | bash -s "$viewNames"
    ;;
"clean-yaml")
    # 📥 Ask user for project name and description
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Name: " projectName
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Description: " projectDescription
    # 🔗 Call remote script with projectName and description as arguments
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/ml.sh | bash -s "$projectName" "$projectDescription"
    ;;
"auto-model")
    echo "📥 Downloading Auto-Model Script..."
    tmpScript=$(mktemp /tmp/auto_model_XXXXXX.sh)

    if curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/mA.sh -o "$tmpScript" 2>/dev/null; then
        chmod +x "$tmpScript"
        echo "🚀 Running Auto-Model Script..."
        bash "$tmpScript"
        rm -f "$tmpScript"
    else
        echo "❌ Failed to  script !"
        echo "💡 Check your internet connection"
        rm -f "$tmpScript"
        exit 1
    fi
    ;;
"make-widget")
    # shellcheck disable=SC2162
    read -p "Enter View Name: " viewName
    # shellcheck disable=SC2162
    read -p "📥 Enter Widget Names (space-separated): " widgetNames
    IFS=' ' read -r -a widgetArray <<< "$widgetNames"
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/widt.sh | bash -s "$viewName" "${widgetArray[@]}"
    ;;
"api-method")
    echo "🛠️ Creating Api Method..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/am.sh | bash
    ;;
#"get-dependencies")
#    echo "🔽 Downloading & applying dependencies..."
#    curl -sSL https://raw.githubusercontent.com/RakibulIslam10/Flutter-Automation/refs/heads/main/py.sh | bash
#    ;;

"setup-firebase")
    echo "📥 Downloading Firebase setup script..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/frbs.sh -o frbs.sh
    chmod +x frbs.sh
    echo "🚀 Running Firebase setup..."
    ./frbs.sh
    ;;
  "make-shaKey")
      echo "🛠️ Creating SHA Key..."
      curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/sa.sh | bash
      ;;
  "delete-unused-assets")
    echo " ----------delete-unused-assets..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/dA.sh | bash -s delete
    ;;
  *)

esac

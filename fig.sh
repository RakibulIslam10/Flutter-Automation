#!/usr/bin/env bash

FIGMA_URL=$1
OUTPUT_FILE=$2

# Extract Figma File Key from URL
FIGMA_KEY=$(echo "$FIGMA_URL" | grep -oP '(?<=figma.com/file/)[^/]+')

if [[ -z "$FIGMA_KEY" ]]; then
  echo "❌ Invalid Figma URL"
  exit 1
fi

# Check for Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Please install Node.js to continue."
  exit 1
fi

# Create a temporary Node.js script to fetch text
TMP_JS=$(mktemp)
cat <<'EOF' > $TMP_JS
const axios = require('axios');
const fs = require('fs');

const FIGMA_KEY = process.argv[2];
const OUTPUT_FILE = process.argv[3];

axios.get(`https://api.figma.com/v1/files/${FIGMA_KEY}`)
  .then(res => {
    const textNodes = [];
    function traverse(node) {
      if (node.type === 'TEXT' && node.characters) {
        const key = node.characters
          .toLowerCase()
          .replace(/[^a-z0-9]+/g, '_')
          .replace(/^_+|_+$/g, '');
        textNodes.push({ key, value: node.characters });
      }
      if (node.children) node.children.forEach(traverse);
    }
    traverse(res.data.document);

    let dartCode = 'class MyText {\n';
    textNodes.forEach(node => {
      dartCode += `  static String ${node.key} = '${node.value.replace(/'/g, "\\'")}';\n`;
    });
    dartCode += '}';

    fs.writeFileSync(OUTPUT_FILE, dartCode, 'utf8');
    console.log(`✅ Dart file created at ${OUTPUT_FILE}`);
  })
  .catch(err => console.error(err));
EOF

# Run the temporary Node.js script
node $TMP_JS "$FIGMA_KEY" "$OUTPUT_FILE"
rm -f $TMP_JS

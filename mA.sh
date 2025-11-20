#!/bin/bash
set -euo pipefail

# -------- Input View Name --------
read -p "📂 Enter View Name: " viewName
if [ -z "$viewName" ]; then
  echo "❌ View name missing!"
  exit 1
fi

# -------- Input Model Name --------
read -p "📦 Enter Model Name: " modelName
if [ -z "$modelName" ]; then
  echo "❌ Model name missing!"
  exit 1
fi

# Directory setup
viewDir="lib/views/${viewName}/model"
mkdir -p "$viewDir"
fileName="${modelName}_model.dart"

# Convert model name like user_info → UserInfoModel
to_pascal() {
  local input="$1"
  local output=""
  IFS='_-' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    output+="${part^}"
  done
  echo "${output}Model"
}

className=$(to_pascal "$modelName")

# -------- JSON Input --------
echo "📥 Paste your JSON below (Finish with CTRL + D):"
jsonInput=$(cat)

if [ -z "$jsonInput" ]; then
  echo "❌ No JSON input found!"
  exit 1
fi

# -------- Python Generator --------
generateModel() {
python3 - "$className" "$jsonInput" <<'PYTHON_SCRIPT'
import sys
import json
import re

class_name = sys.argv[1]
json_str = sys.argv[2]

try:
    data = json.loads(json_str)
except json.JSONDecodeError as e:
    print(f"❌ Invalid JSON: {e}")
    sys.exit(1)

def to_pascal_case(text):
    """Convert snake_case or kebab-case to PascalCase"""
    return ''.join(word.capitalize() for word in re.split(r'[_\-\s]', text) if word)

def to_camel_case(text):
    """Convert to camelCase for field names"""
    if text == '_id':
        return 'id'
    parts = re.split(r'[_\-\s]', text)
    if not parts:
        return text
    # Handle camelCase from JSON (like fullName)
    if text[0].islower() and any(c.isupper() for c in text):
        return text
    return parts[0].lower() + ''.join(word.capitalize() for word in parts[1:])

def singularize(text):
    """Simple singularization for list items"""
    if text.endswith('ies'):
        return text[:-3] + 'y'
    elif text.endswith('ses'):
        return text[:-2]
    elif text.endswith('s'):
        return text[:-1]
    return text

def get_dart_type(value, key_name=""):
    """Determine Dart type from JSON value"""
    if value is None:
        return "dynamic", True  # Nullable
    elif isinstance(value, bool):
        return "bool", False
    elif isinstance(value, int):
        return "int", False
    elif isinstance(value, float):
        return "double", False
    elif isinstance(value, str):
        return "String", False
    elif isinstance(value, list):
        if len(value) == 0:
            return "List<dynamic>", True
        elif isinstance(value[0], dict):
            nested_class = to_pascal_case(singularize(key_name))
            return f"List<{nested_class}>", True
        elif isinstance(value[0], str):
            return "List<String>", False
        elif isinstance(value[0], int):
            return "List<int>", False
        elif isinstance(value[0], bool):
            return "List<bool>", False
        elif isinstance(value[0], float):
            return "List<double>", False
        else:
            return "List<dynamic>", False
    elif isinstance(value, dict):
        nested_class = to_pascal_case(key_name)
        return nested_class, True  # Nested objects are nullable
    else:
        return "dynamic", True

def collect_nested_classes(data, parent_class=""):
    """Collect all nested class definitions in order"""
    nested_classes = []
    
    if not isinstance(data, dict):
        return nested_classes
    
    for json_key, json_value in data.items():
        # Handle nested objects
        if isinstance(json_value, dict):
            nested_class_name = to_pascal_case(json_key)
            # Recursively collect nested classes first
            nested_classes.extend(collect_nested_classes(json_value, nested_class_name))
            nested_classes.append((nested_class_name, json_value))
        
        # Handle list of objects
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
            # Recursively collect nested classes first
            nested_classes.extend(collect_nested_classes(json_value[0], item_class))
            nested_classes.append((item_class, json_value[0]))
    
    return nested_classes

def generate_class_code(class_name, data):
    """Generate Dart class code from JSON object"""
    if not isinstance(data, dict):
        return ""
    
    fields = []
    constructor_params = []
    from_json_lines = []
    
    for json_key, json_value in data.items():
        field_name = to_camel_case(json_key)
        dart_type, is_nullable = get_dart_type(json_value, json_key)
        
        # Handle nested objects
        if isinstance(json_value, dict):
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"this.{field_name}" if is_nullable else f"required this.{field_name}")
            from_json_lines.append(
                f"{field_name}: json['{json_key}'] != null\n          ? {dart_type}.fromJson(json['{json_key}'])\n          : null"
            )
        
        # Handle list of objects
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final List<{item_class}>{nullable_mark} {field_name};")
            constructor_params.append(f"this.{field_name}")
            from_json_lines.append(
                f"{field_name}: json['{json_key}'] != null\n          ? (json['{json_key}'] as List).map((e) => {item_class}.fromJson(e)).toList()\n          : null"
            )
        
        # Handle simple lists
        elif isinstance(json_value, list):
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"this.{field_name}")
            from_json_lines.append(
                f"{field_name}: json['{json_key}'] != null\n          ? List.from(json['{json_key}'])\n          : null"
            )
        
        # Handle primitives
        else:
            nullable_mark = "?" if is_nullable else ""
            required_mark = "required " if not is_nullable else ""
            
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"{required_mark}this.{field_name}")
            from_json_lines.append(f"{field_name}: json['{json_key}']")
    
    # Build class string
    class_str = f"class {class_name} {{\n"
    
    # Fields
    for field in fields:
        class_str += f"  {field}\n"
    
    # Constructor
    class_str += f"\n  {class_name}({{\n"
    for param in constructor_params:
        class_str += f"    {param},\n"
    class_str += f"  }});\n\n"
    
    # fromJson factory
    class_str += f"  factory {class_name}.fromJson(Map<String, dynamic> json) {{\n"
    class_str += f"    return {class_name}(\n"
    for line in from_json_lines:
        class_str += f"      {line},\n"
    class_str += f"    );\n"
    class_str += f"  }}\n"
    
    class_str += f"}}\n"
    
    return class_str

# Collect all nested classes
all_nested_classes = collect_nested_classes(data)

# Remove duplicates while preserving order
seen = set()
unique_nested_classes = []
for class_name, class_data in all_nested_classes:
    if class_name not in seen:
        seen.add(class_name)
        unique_nested_classes.append((class_name, class_data))

# Generate main class first
output = generate_class_code(class_name, data)
output += "\n"

# Generate nested classes in order
for nested_class_name, nested_class_data in unique_nested_classes:
    output += generate_class_code(nested_class_name, nested_class_data)
    output += "\n"

# Print output
print(output.rstrip())
PYTHON_SCRIPT
}

# -------- Write Model to File --------
echo "⚙️ Generating model..."
dartModel=$(generateModel)

if [ -z "$dartModel" ]; then
  echo "❌ Model generation failed!"
  exit 1
fi

echo "$dartModel" > "$viewDir/$fileName"
echo "✅ Model generated successfully at: $viewDir/$fileName"
echo "📄 File: $fileName"

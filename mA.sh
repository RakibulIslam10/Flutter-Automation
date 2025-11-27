#!/bin/bash
set -euo pipefail

# ==================== Configuration ====================
echo "╔═══════════════════════════════════════════════════╗"
echo "║      Dart Model Generator (JSON to Dart)         ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# -------- Input View Name --------
read -p "📂 Enter View Name: " viewName
if [ -z "$viewName" ]; then
  echo "❌ View name is required!"
  exit 1
fi

# -------- Input Model Name --------
read -p "📦 Enter Model Name: " modelName
if [ -z "$modelName" ]; then
  echo "❌ Model name is required!"
  exit 1
fi

# Directory setup
viewDir="lib/views/${viewName}/model"
mkdir -p "$viewDir"

# Convert model name to PascalCase
to_pascal() {
  local input="$1"
  IFS='_-' read -ra parts <<< "$input"
  local output=""
  for part in "${parts[@]}"; do
    output+="${part^}"
  done
  echo "${output}Model"
}

className=$(to_pascal "$modelName")
fileName="${modelName}_model.dart"

# -------- JSON Input --------
echo ""
echo "📥 Paste your JSON below and press Enter:"
read -r jsonInput

if [ -z "$jsonInput" ]; then
  echo "❌ No JSON input provided!"
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
    print(f"❌ Invalid JSON: {e}", file=sys.stderr)
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
    # Preserve existing camelCase
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

def is_date_string(value):
    """Check if string looks like ISO date"""
    if not isinstance(value, str):
        return False
    # Match ISO 8601 format
    pattern = r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'
    return bool(re.match(pattern, value))

def get_dart_type(value, key_name=""):
    """Determine Dart type from JSON value"""
    if value is None:
        return "dynamic", True
    elif isinstance(value, bool):
        return "bool", False
    elif isinstance(value, int):
        return "int", False
    elif isinstance(value, float):
        return "double", False
    elif isinstance(value, str):
        if is_date_string(value):
            return "DateTime", False
        return "String", False
    elif isinstance(value, list):
        if len(value) == 0:
            return "List<dynamic>", True
        first_item = value[0]
        if isinstance(first_item, dict):
            nested_class = to_pascal_case(singularize(key_name))
            return f"List<{nested_class}>", False
        elif isinstance(first_item, str):
            return "List<String>", False
        elif isinstance(first_item, int):
            return "List<int>", False
        elif isinstance(first_item, bool):
            return "List<bool>", False
        elif isinstance(first_item, float):
            return "List<double>", False
        else:
            return "List<dynamic>", False
    elif isinstance(value, dict):
        nested_class = to_pascal_case(key_name)
        return nested_class, False
    else:
        return "dynamic", True

def collect_nested_classes(data, parent_class=""):
    """Collect all nested class definitions"""
    nested_classes = []
    
    if not isinstance(data, dict):
        return nested_classes
    
    for json_key, json_value in data.items():
        if isinstance(json_value, dict):
            nested_class_name = to_pascal_case(json_key)
            nested_classes.extend(collect_nested_classes(json_value, nested_class_name))
            nested_classes.append((nested_class_name, json_value))
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
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
            fields.append(f"  final {dart_type} {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(f"    {field_name}: {dart_type}.fromJson(json[\"{json_key}\"]),")
        
        # Handle list of objects
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
            fields.append(f"  final List<{item_class}> {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(
                f"    {field_name}: List<{item_class}>.from(json[\"{json_key}\"].map((x) => {item_class}.fromJson(x))),"
            )
        
        # Handle empty lists
        elif isinstance(json_value, list) and len(json_value) == 0:
            nullable_mark = "?"
            fields.append(f"  final List<dynamic>{nullable_mark} {field_name};")
            constructor_params.append(f"    this.{field_name},")
            from_json_lines.append(f"    {field_name}: json[\"{json_key}\"] != null ? List.from(json[\"{json_key}\"]) : null,")
        
        # Handle simple lists
        elif isinstance(json_value, list):
            fields.append(f"  final {dart_type} {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(f"    {field_name}: List.from(json[\"{json_key}\"]),")
        
        # Handle DateTime
        elif dart_type == "DateTime":
            fields.append(f"  final DateTime {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(f"    {field_name}: DateTime.parse(json[\"{json_key}\"]),")
        
        # Handle primitives
        else:
            nullable_mark = "?" if is_nullable else ""
            required_mark = "required " if not is_nullable else ""
            
            fields.append(f"  final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"    {required_mark}this.{field_name},")
            from_json_lines.append(f"    {field_name}: json[\"{json_key}\"],")
    
    # Build class string
    class_str = f"class {class_name} {{\n"
    class_str += '\n'.join(fields)
    class_str += f"\n\n  {class_name}({{\n"
    class_str += '\n'.join(constructor_params)
    class_str += f"\n  }});\n\n"
    class_str += f"  factory {class_name}.fromJson(Map<String, dynamic> json) => {class_name}(\n"
    class_str += '\n'.join(from_json_lines)
    class_str += f"\n  );\n"
    class_str += f"}}\n"
    
    return class_str

# Collect nested classes
all_nested_classes = collect_nested_classes(data)

# Remove duplicates
seen = set()
unique_nested_classes = []
for cls_name, cls_data in all_nested_classes:
    if cls_name not in seen:
        seen.add(cls_name)
        unique_nested_classes.append((cls_name, cls_data))

# Generate main class first
output = generate_class_code(class_name, data)

# Generate nested classes
for nested_class_name, nested_class_data in unique_nested_classes:
    output += "\n"
    output += generate_class_code(nested_class_name, nested_class_data)

print(output.rstrip())
PYTHON_SCRIPT
}

# -------- Write Model to File --------
echo ""
echo "⚙️  Generating Dart model..."
dartModel=$(generateModel)

if [ -z "$dartModel" ]; then
  echo "❌ Model generation failed!"
  exit 1
fi

echo "$dartModel" > "$viewDir/$fileName"

echo ""
echo "✅ Model generated successfully!"
echo "📁 Location: $viewDir/$fileName"
echo "📄 File: $fileName"
echo "🎯 Class: $className"
echo ""

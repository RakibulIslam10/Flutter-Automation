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
echo "📥 Paste your JSON (single line, press Enter when done):"
read -r jsonInput

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
    return ''.join(word.capitalize() for word in re.split(r'[_\-\s]', text) if word)

def to_camel_case(text):
    if text == '_id':
        return 'id'
    parts = re.split(r'[_\-\s]', text)
    if not parts:
        return text
    if text[0].islower() and any(c.isupper() for c in text):
        return text
    return parts[0].lower() + ''.join(word.capitalize() for word in parts[1:])

def singularize(text):
    if text.endswith('ies'):
        return text[:-3] + 'y'
    elif text.endswith('ses'):
        return text[:-2]
    elif text.endswith('s'):
        return text[:-1]
    return text

def get_dart_type(value, key_name=""):
    if value is None:
        return "dynamic", True
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
        return nested_class, True
    else:
        return "dynamic", True

def generate_class(class_name, data, indent=0):
    if not isinstance(data, dict):
        return []
    
    ind = "  " * indent
    classes = []
    fields = []
    constructor_params = []
    from_json_lines = []
    to_json_lines = []
    
    for json_key, json_value in data.items():
        field_name = to_camel_case(json_key)
        dart_type, is_nullable = get_dart_type(json_value, json_key)
        
        if isinstance(json_value, dict):
            nested_classes = generate_class(dart_type, json_value, indent)
            classes.extend(nested_classes)
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"required this.{field_name}" if not is_nullable else f"this.{field_name}")
            from_json_lines.append(
                f"{field_name}: json['{json_key}'] != None ? {dart_type}.fromJson(json['{json_key}']) : None"
            )
            to_json_lines.append(f"'{json_key}': {field_name}?.toJson()")
        
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
            nested_classes = generate_class(item_class, json_value[0], indent)
            classes.extend(nested_classes)
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final List<{item_class}>{nullable_mark} {field_name};")
            constructor_params.append(f"this.{field_name}")
            from_json_lines.append(
                f"{field_name}: json['{json_key}'] != None ? [ {item_class}.fromJson(e) for e in json['{json_key}'] ] : None"
            )
            to_json_lines.append(f"'{json_key}': {field_name}?.map((e) => e.toJson()).toList()")
        
        elif isinstance(json_value, list):
            nullable_mark = "?" if is_nullable else ""
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"this.{field_name}")
            from_json_lines.append(f"{field_name}: json['{json_key}'] != None ? list(json['{json_key}']) : None")
            to_json_lines.append(f"'{json_key}': {field_name}")
        
        else:
            nullable_mark = "?" if is_nullable else ""
            required_mark = "required " if not is_nullable else ""
            fields.append(f"final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"{required_mark}this.{field_name}")
            from_json_lines.append(f"{field_name}: json['{json_key}']")
            to_json_lines.append(f"'{json_key}': {field_name}")
    
    class_str = f"{ind}class {class_name} {{\n"
    for field in fields:
        class_str += f"{ind}  {field}\n"
    
    class_str += f"\n{ind}  {class_name}({{\n"
    for param in constructor_params:
        class_str += f"{ind}    {param},\n"
    class_str += f"{ind}  }});\n\n"
    
    class_str += f"{ind}  factory {class_name}.fromJson(Map<String, dynamic> json) {{\n"
    class_str += f"{ind}    return {class_name}(\n"
    for line in from_json_lines:
        class_str += f"{ind}      {line},\n"
    class_str += f"{ind}    );\n"
    class_str += f"{ind}  }}\n\n"
    
    class_str += f"{ind}  Map<String, dynamic> toJson() {{\n"
    class_str += f"{ind}    return {{\n"
    for line in to_json_lines:
        class_str += f"{ind}      {line},\n"
    class_str += f"{ind}    }};\n"
    class_str += f"{ind}  }}\n"
    
    class_str += f"{ind}}}\n"
    
    classes.append(class_str)
    return classes

all_classes = generate_class(class_name, data)
print("\n".join(all_classes))
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

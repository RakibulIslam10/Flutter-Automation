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
python3 - "$className" "$jsonInput" <<'EOF'
import sys, json, re

class_name = sys.argv[1]
data = json.loads(sys.argv[2])

def pascal(text):
    return ''.join(word.capitalize() for word in re.split(r'_|-|\s', text))

def fix_field_name(name):
    return 'id' if name == '_id' else name

def determine_type(value):
    if isinstance(value, str):
        return "String", True
    elif isinstance(value, bool):
        return "bool", True
    elif isinstance(value, int):
        return "int", True
    elif isinstance(value, float):
        return "double", True
    elif isinstance(value, list):
        return "List<dynamic>", False
    elif isinstance(value, dict):
        return None, False
    else:
        return "dynamic", True

def generate_class(name, obj):
    lines = []
    fields = ""
    from_json = ""
    to_json = ""

    for key, value in obj.items():
        field_name = fix_field_name(key)
        dart_type, required = determine_type(value)
        nullable = "" if required else "?"
        
        # Nested dict
        if isinstance(value, dict):
            nested_name = pascal(key)
            lines.extend(generate_class(nested_name, value))
            dart_type = nested_name
            nullable = "?"
            from_json_line = f"{field_name}: json['{key}'] != None ? {dart_type}.fromJson(json['{key}']) : null,"
            to_json_line = f"'{key}': {field_name}?.toJson(),"
        # List of objects
        elif isinstance(value, list) and len(value) > 0 and isinstance(value[0], dict):
            nested_name = pascal(key)
            lines.extend(generate_class(nested_name, value[0]))
            dart_type = f"List<{nested_name}>"
            nullable = "?"
            from_json_line = f"{field_name}: (json['{key}'] as List<dynamic>?)?.map((x) => {nested_name}.fromJson(x)).toList() ?? [],"
            to_json_line = f"'{key}': {field_name}?.map((x) => x.toJson()).toList(),"
        # Simple list
        elif isinstance(value, list):
            from_json_line = f"{field_name}: (json['{key}'] as List<dynamic>?) ?? [],"
            to_json_line = f"'{key}': {field_name},"
        else:
            from_json_line = f"{field_name}: json['{key}'],"
            to_json_line = f"'{key}': {field_name},"

        fields += f"  final {dart_type}{nullable} {field_name};\n"
        from_json += f"      {from_json_line}\n"
        to_json += f"      {to_json_line}\n"

    cls = f"""
class {name} {{
{fields}
  {name}({{
{''.join([f'    required this.{line.split()[2][:-1]},\n' for line in fields.splitlines() if line.strip() and '?' not in line])}  }});

  factory {name}.fromJson(Map<String, dynamic> json) => {name}(
{from_json}
  );

  Map<String, dynamic> toJson() => {{
{to_json}
  }};
}}
"""
    lines.append(cls)
    return lines

output = generate_class(class_name, data)
print("\n".join(output))
EOF
}

# -------- Write Model to File --------
echo "⚙️ Generating model..."
dartModel=$(generateModel)
echo "$dartModel" > "$viewDir/$fileName"

echo "✅ Model generated successfully!"
echo "📄 Saved to: $viewDir/$fileName"

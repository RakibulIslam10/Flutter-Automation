#!/bin/bash

# ============================
# ============================

read -p "📂 Enter View Name: " viewName
read -p "📦 Enter Model Name: " modelName

if [ -z "$viewName" ] || [ -z "$modelName" ]; then
  echo "❌ View name or Model name missing!"
  exit 1
fi

# Directory structure
viewDir="lib/views/${viewName}/model"
mkdir -p "$viewDir"

fileName="${modelName}_model.dart"

# Convert model name to PascalCase + Model
className="$(echo $modelName | sed -r 's/(^|-)(\w)/\U\2/g')Model"

echo "📥 Paste your JSON below (finish with CTRL + D):"

jsonInput=$(cat)

if [ -z "$jsonInput" ]; then
  echo "❌ No JSON found!"
  exit 1
fi

# ----- Dart Model Generator -----
generateModel() {
python3 - "$className" "$jsonInput" << 'EOF'
import sys, json, re

def pascal_case(text):
    return ''.join(word.capitalize() for word in re.split(r'_|-|\s', text))

class_name = sys.argv[1]
data = json.loads(sys.argv[2])

def generate_class(name, obj):
    lines = []
    fields = ""
    from_json = ""
    to_json = ""

    for key, value in obj.items():
        field_name = key
        json_key = key

        # Determine type
        if isinstance(value, str):
            dart_type = "String"
        elif isinstance(value, bool):
            dart_type = "bool"
        elif isinstance(value, int):
            dart_type = "int"
        elif isinstance(value, float):
            dart_type = "double"
        elif isinstance(value, list):
            if len(value) > 0 and isinstance(value[0], dict):
                sub = pascal_case(key)
                lines.extend(generate_class(sub, value[0]))
                dart_type = f"List<{sub}>"
            else:
                dart_type = "List<dynamic>"
        elif isinstance(value, dict):
            sub = pascal_case(key)
            lines.extend(generate_class(sub, value))
            dart_type = sub
        else:
            dart_type = "dynamic"

        fields += f"  final {dart_type} {field_name};\n"

        # fromJson
        if "List<" in dart_type:
            base = dart_type.replace("List<","").replace(">","")
            if base in ["String","int","double","bool","dynamic"]:
                from_json += f"      {field_name}: List<{base}>.from(json['{json_key}'] ?? []),\n"
            else:
                from_json += f"      {field_name}: json['{json_key}'] != null ? List<{base}>.from(json['{json_key}'].map((x) => {base}.fromJson(x))) : [],\n"
        elif dart_type[0].isupper() and dart_type not in ["String","bool","int","double"]:
            from_json += f"      {field_name}: json['{json_key}'] != null ? {dart_type}.fromJson(json['{json_key}']) : null,\n"
        else:
            from_json += f"      {field_name}: json['{json_key}'],\n"

        # toJson
        if "List<" in dart_type:
            base = dart_type.replace("List<","").replace(">","")
            if base in ["String","int","double","bool","dynamic"]:
                to_json += f"      '{json_key}': {field_name},\n"
            else:
                to_json += f"      '{json_key}': {field_name}.map((x) => x.toJson()).toList(),\n"
        elif dart_type[0].isupper() and dart_type not in ["String","bool","int","double"]:
            to_json += f"      '{json_key}': {field_name}?.toJson(),\n"
        else:
            to_json += f"      '{json_key}': {field_name},\n"

    cls = f"""
class {name} {{
{fields}
  {name}({{
{''.join([f'    required this.{f.split()[2][:-1]},\n' for f in fields.splitlines() if f.strip()])}  }});

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

echo "⚙️ Generating model..."
dartModel=$(generateModel)

echo "$dartModel" > "$viewDir/$fileName"

echo "✅ Model generated successfully!"

#!/bin/bash
set -euo pipefail

# ==================== Configuration ====================
echo "╔═══════════════════════════════════════════════════╗"
echo "║   Production-Ready Dart Model Generator v2.0     ║"
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

# -------- JSON Input (Multiline) --------
echo ""
echo "📥 Paste your JSON below (Press CTRL+D when done):"
echo "───────────────────────────────────────────────────"
jsonInput=$(cat)

if [ -z "$jsonInput" ]; then
  echo "❌ No JSON input provided!"
  exit 1
fi

# -------- Python Generator --------
generateModel() {
python3 <<PYTHON_SCRIPT
import sys
import json
import re
from typing import Any, Dict, List, Tuple, Set

json_str = '''$jsonInput'''
class_name = "$className"

try:
    data = json.loads(json_str)
except json.JSONDecodeError as e:
    print(f"❌ Invalid JSON: {e}", file=sys.stderr)
    sys.exit(1)

def to_pascal_case(text: str) -> str:
    """Convert snake_case or kebab-case to PascalCase"""
    # Handle already PascalCase/camelCase
    if text and text[0].isupper():
        return text
    return ''.join(word.capitalize() for word in re.split(r'[_\-\s]', text) if word)

def to_camel_case(text: str) -> str:
    """Convert to camelCase for field names"""
    if text == '_id' or text == 'id':
        return 'id'
    
    # Preserve existing camelCase
    if text and text[0].islower() and any(c.isupper() for c in text):
        return text
    
    parts = re.split(r'[_\-\s]', text)
    if not parts:
        return text
    
    return parts[0].lower() + ''.join(word.capitalize() for word in parts[1:])

def singularize(text: str) -> str:
    """Enhanced singularization for list items"""
    original = text
    text = text.lower()
    
    # Common irregular plurals
    irregulars = {
        'people': 'person',
        'children': 'child',
        'men': 'man',
        'women': 'woman',
        'teeth': 'tooth',
        'feet': 'foot',
        'geese': 'goose',
        'mice': 'mouse',
        'data': 'datum',
        'criteria': 'criterion',
        'phenomena': 'phenomenon',
    }
    
    if text in irregulars:
        return irregulars[text]
    
    # Words ending in 'ies' -> 'y' (categories → category)
    if text.endswith('ies') and len(text) > 3:
        return text[:-3] + 'y'
    
    # Words ending in 'ves' -> 'fe' or 'f' (knives → knife)
    if text.endswith('ves') and len(text) > 3:
        if text[:-3] + 'f' in ['shelf', 'self', 'elf', 'half', 'calf', 'leaf', 'loaf', 'thief', 'sheaf', 'knife', 'life', 'wife']:
            return text[:-3] + 'fe'
        return text[:-3] + 'f'
    
    # Words ending in 'ses' -> 's' (classes → class, courses → course)
    if text.endswith('ses') and len(text) > 3:
        return text[:-2]
    
    # Words ending in 'xes', 'ches', 'shes', 'sses' -> remove 'es'
    if len(text) > 3 and text.endswith(('xes', 'ches', 'shes', 'sses')):
        return text[:-2]
    
    # Words ending in 'oes' -> 'o' (heroes → hero, tomatoes → tomato)
    if text.endswith('oes') and len(text) > 3:
        return text[:-2]
    
    # Words ending in 'zes' -> 'ze' (prizes → prize)
    if text.endswith('zes') and len(text) > 3:
        return text[:-1]
    
    # Default: just remove 's' if word ends with 's'
    if text.endswith('s') and len(text) > 1 and not text.endswith('ss'):
        return text[:-1]
    
    return original

def is_date_string(value: Any) -> bool:
    """Check if string looks like ISO date or common date formats"""
    if not isinstance(value, str):
        return False
    
    patterns = [
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}',  # ISO 8601
        r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}',  # YYYY-MM-DD HH:MM:SS
        r'^\d{4}/\d{2}/\d{2}',                     # YYYY/MM/DD
    ]
    
    return any(re.match(pattern, value) for pattern in patterns)

def get_dart_type(value: Any, key_name: str = "") -> Tuple[str, bool]:
    """Determine Dart type from JSON value with proper nullable handling"""
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

def collect_nested_classes(data: Any, parent_class: str = "", depth: int = 0) -> List[Tuple[str, Dict, int]]:
    """Recursively collect all nested class definitions with depth tracking"""
    nested_classes = []
    
    if not isinstance(data, dict):
        return nested_classes
    
    for json_key, json_value in data.items():
        # Handle nested objects
        if isinstance(json_value, dict):
            nested_class_name = to_pascal_case(json_key)
            nested_classes.extend(collect_nested_classes(json_value, nested_class_name, depth + 1))
            nested_classes.append((nested_class_name, json_value, depth))
        
        # Handle list of objects
        elif isinstance(json_value, list) and len(json_value) > 0 and isinstance(json_value[0], dict):
            item_class = to_pascal_case(singularize(json_key))
            nested_classes.extend(collect_nested_classes(json_value[0], item_class, depth + 1))
            nested_classes.append((item_class, json_value[0], depth))
    
    return nested_classes

def generate_class_code(class_name: str, data: Dict) -> str:
    """Generate complete Dart class with fromJson method"""
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
                f"    {field_name}: (json[\"{json_key}\"] as List<dynamic>).map((x) => {item_class}.fromJson(x as Map<String, dynamic>)).toList(),"
            )
        
        # Handle empty lists with safe nullable handling
        elif isinstance(json_value, list) and len(json_value) == 0:
            fields.append(f"  final List<dynamic>? {field_name};")
            constructor_params.append(f"    this.{field_name},")
            from_json_lines.append(f"    {field_name}: json[\"{json_key}\"] != null ? List<dynamic>.from(json[\"{json_key}\"]) : null,")
        
        # Handle simple lists
        elif isinstance(json_value, list):
            fields.append(f"  final {dart_type} {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(f"    {field_name}: List.from(json[\"{json_key}\"]),")
        
        # Handle DateTime with safe parsing
        elif dart_type == "DateTime":
            fields.append(f"  final DateTime {field_name};")
            constructor_params.append(f"    required this.{field_name},")
            from_json_lines.append(f"    {field_name}: DateTime.parse(json[\"{json_key}\"]),")
        
        # Handle primitives with proper null safety
        else:
            nullable_mark = "?" if is_nullable else ""
            required_mark = "required " if not is_nullable else ""
            
            fields.append(f"  final {dart_type}{nullable_mark} {field_name};")
            constructor_params.append(f"    {required_mark}this.{field_name},")
            from_json_lines.append(f"    {field_name}: json[\"{json_key}\"],")
    
    # Build class string with fromJson only
    class_str = f"class {class_name} {{\n"
    class_str += '\n'.join(fields)
    class_str += f"\n\n  {class_name}({{\n"
    class_str += '\n'.join(constructor_params)
    class_str += f"\n  }});\n\n"
    
    # fromJson factory
    class_str += f"  factory {class_name}.fromJson(Map<String, dynamic> json) => {class_name}(\n"
    class_str += '\n'.join(from_json_lines)
    class_str += f"\n  );\n"
    
    class_str += f"}}\n"
    
    return class_str

# Collect all nested classes with depth
all_nested_classes = collect_nested_classes(data)

# Remove duplicates while preserving order and depth
seen: Set[str] = set()
unique_nested_classes: List[Tuple[str, Dict, int]] = []
for cls_name, cls_data, depth in all_nested_classes:
    if cls_name not in seen:
        seen.add(cls_name)
        unique_nested_classes.append((cls_name, cls_data, depth))

# Sort by depth (shallowest first = main classes first)
unique_nested_classes.sort(key=lambda x: x[2])

# Generate main class first
output = generate_class_code(class_name, data)
output += "\n"

# Generate nested classes sorted by hierarchy (top to bottom)
for nested_class_name, nested_class_data, _ in unique_nested_classes:
    output += generate_class_code(nested_class_name, nested_class_data)
    output += "\n"

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
echo "🚀 Features included:"
echo "   ✓ Null safety support"
echo "   ✓ fromJson() factory constructor"
echo "   ✓ Nested classes support"
echo "   ✓ DateTime parsing"
echo "   ✓ Type-safe list handling"
echo ""

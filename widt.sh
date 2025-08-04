view_dir="lib/views/$viewName"
widget_dir="$view_dir/widget"
main_view_file="$view_dir/screen/${viewName}_screen.dart"

# চেক স্ক্রীন ফাইল আছে কিনা
if [ ! -f "$main_view_file" ]; then
  echo "❌ Main screen file $main_view_file found na! স্ক্রিপ্ট বন্ধ।"
  exit 1
fi

for widgetName in "$@"; do
  file="$widget_dir/${widgetName}.dart"
  className=$(to_pascal_case "$widgetName")

  echo "🧱 Generating widget: $widgetName → class $className"

  # উইজেট ফাইল তৈরি (overwrite করে)
  cat <<EOF > "$file"
part of '../screen/${viewName}_screen.dart';

class ${className} extends StatelessWidget {
  const ${className}({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$className'),
    );
  }
}
EOF

  # main screen এ part লাইন যোগ করো যদি না থাকে
  part_line="part 'widget/${widgetName}.dart';"
  if ! grep -Fxq "$part_line" "$main_view_file"; then
    echo "$part_line" >> "$main_view_file"
    echo "✅ Added part directive for $widgetName"
  fi
done

echo "✅ Widgets generated and linked successfully!"

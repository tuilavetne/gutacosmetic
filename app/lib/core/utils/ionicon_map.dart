import 'package:material_ui/material_ui.dart';

/// Map tên icon Ionicons (lưu trong `Product.ingredients[].icon`) sang
/// Material Icons. Tên không có trong bảng dùng [defaultIngredientIcon].
const defaultIngredientIcon = Icons.eco_outlined;

const _ioniconToMaterial = <String, IconData>{
  'water': Icons.water_drop,
  'water-outline': Icons.water_drop_outlined,
  'leaf': Icons.eco,
  'leaf-outline': Icons.eco_outlined,
  'shield-checkmark': Icons.verified_user,
  'shield-checkmark-outline': Icons.verified_user_outlined,
  'shield': Icons.shield,
  'shield-outline': Icons.shield_outlined,
  'sunny': Icons.wb_sunny,
  'sunny-outline': Icons.wb_sunny_outlined,
  'moon': Icons.nightlight,
  'moon-outline': Icons.nightlight_outlined,
  'sparkles': Icons.auto_awesome,
  'sparkles-outline': Icons.auto_awesome_outlined,
  'flask': Icons.science,
  'flask-outline': Icons.science_outlined,
  'beaker': Icons.science,
  'beaker-outline': Icons.science_outlined,
  'flower': Icons.local_florist,
  'flower-outline': Icons.local_florist_outlined,
  'rose': Icons.local_florist,
  'rose-outline': Icons.local_florist_outlined,
  'heart': Icons.favorite,
  'heart-outline': Icons.favorite_border,
  'star': Icons.star,
  'star-outline': Icons.star_border,
  'flash': Icons.bolt,
  'flash-outline': Icons.bolt_outlined,
  'snow': Icons.ac_unit,
  'snow-outline': Icons.ac_unit_outlined,
  'flame': Icons.local_fire_department,
  'flame-outline': Icons.local_fire_department_outlined,
  'happy': Icons.sentiment_satisfied,
  'happy-outline': Icons.sentiment_satisfied_outlined,
  'medkit': Icons.medical_services,
  'medkit-outline': Icons.medical_services_outlined,
  'nutrition': Icons.local_dining,
  'nutrition-outline': Icons.local_dining_outlined,
  'diamond': Icons.diamond,
  'diamond-outline': Icons.diamond_outlined,
  'color-palette': Icons.palette,
  'color-palette-outline': Icons.palette_outlined,
  'checkmark-circle': Icons.check_circle,
  'checkmark-circle-outline': Icons.check_circle_outline,
  'cloud': Icons.cloud,
  'cloud-outline': Icons.cloud_outlined,
  'body': Icons.accessibility_new,
  'body-outline': Icons.accessibility_new_outlined,
  'fitness': Icons.fitness_center,
  'fitness-outline': Icons.fitness_center_outlined,
  'eyedrop': Icons.colorize,
  'eyedrop-outline': Icons.colorize_outlined,
  'bandage': Icons.healing,
  'bandage-outline': Icons.healing_outlined,
  'thermometer': Icons.thermostat,
  'thermometer-outline': Icons.thermostat_outlined,
};

IconData materialIconForIonicon(String? name) {
  if (name == null || name.isEmpty) return defaultIngredientIcon;
  final key = name.trim().toLowerCase().replaceFirst(RegExp(r'^(ios|md)-'), '');
  return _ioniconToMaterial[key] ?? defaultIngredientIcon;
}

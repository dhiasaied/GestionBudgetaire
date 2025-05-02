import 'package:uuid/uuid.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;

  Category({
    String? id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      icon: map['icon'],
      color: map['color'],
    );
  }
}

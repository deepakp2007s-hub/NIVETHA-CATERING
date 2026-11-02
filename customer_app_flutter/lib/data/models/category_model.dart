class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
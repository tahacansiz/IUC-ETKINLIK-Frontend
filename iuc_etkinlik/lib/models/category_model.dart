/// Kategori modeli
/// Etkinlik kategorilerini temsil eder
library;

/// Kategori modeli
class CategoryModel {
  final String id;
  final String name;
  final String? iconName; // Material icon adı
  final String? colorHex; // Renk kodu

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
  });

  /// JSON'dan CategoryModel oluşturma
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
    );
  }

  /// CategoryModel'i JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  /// copyWith metodu
  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

/// Önceden tanımlı kategoriler (Mock data)
class PredefinedCategories {
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      name: 'Konferans',
      iconName: 'mic',
      colorHex: '#FF5722',
    ),
    CategoryModel(
      id: '2',
      name: 'Workshop',
      iconName: 'build',
      colorHex: '#2196F3',
    ),
    CategoryModel(
      id: '3',
      name: 'Seminer',
      iconName: 'school',
      colorHex: '#4CAF50',
    ),
    CategoryModel(
      id: '4',
      name: 'Spor',
      iconName: 'sports_soccer',
      colorHex: '#FF9800',
    ),
    CategoryModel(
      id: '5',
      name: 'Müzik',
      iconName: 'music_note',
      colorHex: '#9C27B0',
    ),
    CategoryModel(
      id: '6',
      name: 'Sanat',
      iconName: 'palette',
      colorHex: '#E91E63',
    ),
    CategoryModel(
      id: '7',
      name: 'Kariyer',
      iconName: 'work',
      colorHex: '#607D8B',
    ),
    CategoryModel(
      id: '8',
      name: 'Sosyal',
      iconName: 'groups',
      colorHex: '#00BCD4',
    ),
  ];

  /// ID'ye göre kategori bul
  static CategoryModel? findById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

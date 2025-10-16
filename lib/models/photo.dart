import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final String id;
  final String url;
  final String description;
  final String location;
  final String createdBy;
  final DateTime createdAt;
  final DateTime takenAt;

  const Photo({
    required this.id,
    required this.url,
    required this.description,
    required this.location,
    required this.createdBy,
    required this.createdAt,
    required this.takenAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      takenAt: DateTime.parse(json['takenAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'takenAt': takenAt.toIso8601String(),
    };
  }

  Photo copyWith({
    String? id,
    String? url,
    String? description,
    String? location,
    String? createdBy,
    DateTime? createdAt,
    DateTime? takenAt,
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      description: description ?? this.description,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    description,
    location,
    createdBy,
    createdAt,
    takenAt,
  ];

  @override
  String toString() {
    return 'Photo{id: $id, url: $url, description: $description, location: $location, createdBy: $createdBy, createdAt: $createdAt, takenAt: $takenAt}';
  }
}

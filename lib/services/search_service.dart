import '../models/photo.dart';

class SearchService {
  /// Filter photos by keyword across description, location, and createdBy
  static List<Photo> searchPhotos(List<Photo> photos, String keyword) {
    if (keyword.isEmpty) return photos;

    final lowerKeyword = keyword.toLowerCase();

    return photos.where((photo) {
      return _containsExactWord(
            photo.description.toLowerCase(),
            lowerKeyword,
          ) ||
          _containsExactWord(photo.location.toLowerCase(), lowerKeyword) ||
          _containsExactWord(photo.createdBy.toLowerCase(), lowerKeyword);
    }).toList();
  }

  /// Check if text contains the exact word (not substring)
  static bool _containsExactWord(String text, String word) {
    // Split text into words and check if any word exactly matches
    final words = text.split(RegExp(r'\s+'));
    return words.any((w) => w == word);
  }

  /// Sort photos by creation date (newest first)
  static List<Photo> sortPhotosByDate(List<Photo> photos) {
    final sortedPhotos = List<Photo>.from(photos);
    sortedPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPhotos;
  }
}

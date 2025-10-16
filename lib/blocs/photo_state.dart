import 'package:equatable/equatable.dart';
import '../models/photo.dart';

abstract class PhotoState extends Equatable {
  const PhotoState();

  @override
  List<Object?> get props => [];
}

class PhotoInitial extends PhotoState {
  const PhotoInitial();
}

class PhotoLoading extends PhotoState {
  const PhotoLoading();
}

class PhotoLoaded extends PhotoState {
  final List<Photo> photos;
  final String? searchKeyword;
  final bool isSearching;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;
  final bool isLoadingMore;

  const PhotoLoaded({
    required this.photos,
    this.searchKeyword,
    this.isSearching = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    photos,
    searchKeyword,
    isSearching,
    currentPage,
    totalPages,
    hasMorePages,
    isLoadingMore,
  ];

  PhotoLoaded copyWith({
    List<Photo>? photos,
    String? searchKeyword,
    bool? isSearching,
    int? currentPage,
    int? totalPages,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return PhotoLoaded(
      photos: photos ?? this.photos,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      isSearching: isSearching ?? this.isSearching,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PhotoError extends PhotoState {
  final String message;

  const PhotoError(this.message);

  @override
  List<Object?> get props => [message];
}

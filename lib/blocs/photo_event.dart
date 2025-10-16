import 'package:equatable/equatable.dart';

abstract class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhotos extends PhotoEvent {
  const LoadPhotos();
}

class SearchPhotos extends PhotoEvent {
  final String keyword;

  const SearchPhotos(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ClearSearch extends PhotoEvent {
  const ClearSearch();
}

class RefreshPhotos extends PhotoEvent {
  const RefreshPhotos();
}

class LoadMorePhotos extends PhotoEvent {
  const LoadMorePhotos();
}

class GoToPage extends PhotoEvent {
  final int page;
  const GoToPage(this.page);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_pagination/number_pagination.dart';
import '../blocs/photo_bloc.dart';
import '../blocs/photo_event.dart';
import '../blocs/photo_state.dart';
import '../models/photo.dart';
import '../widgets/preloaded_image_widget.dart';
import '../utils/constants.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load photos only if not already loaded
    final photoBloc = context.read<PhotoBloc>();
    if (photoBloc.state is PhotoInitial) {
      photoBloc.add(const LoadPhotos());
    }
    _searchController.addListener(
      () => _onSearchChanged(_searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // Trigger UI rebuild for clear button visibility

    final photoBloc = context.read<PhotoBloc>();
    if (value.isEmpty) {
      // Only clear search if we're currently in a search state
      if (photoBloc.state is PhotoLoaded &&
          (photoBloc.state as PhotoLoaded).isSearching) {
        photoBloc.add(const ClearSearch());
      }
    } else {
      // Only search if there's actual text
      photoBloc.add(SearchPhotos(value));
    }
  }

  void _navigateToPhotoDetail(Photo photo) {
    Navigator.pushNamed(context, '/detail', arguments: photo);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Remove focus from search bar when tapping outside
        setState(() {
          _searchFocusNode.unfocus();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PicPulse', style: TextStyle(fontSize: 24)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search photos by keyword...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus(); // Remove focus
                            context.read<PhotoBloc>().add(const ClearSearch());
                          },
                        )
                      : _searchFocusNode.hasFocus
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchFocusNode.unfocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            // Photo Grid
            Expanded(
              child: BlocBuilder<PhotoBloc, PhotoState>(
                builder: (context, state) {
                  if (state is PhotoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PhotoError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<PhotoBloc>().add(
                              const RefreshPhotos(),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PhotoLoaded) {
                    if (state.photos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.isSearching
                                  ? Icons.search_off
                                  : Icons.photo_library_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.isSearching
                                  ? 'No photos found for "${state.searchKeyword}"'
                                  : 'No photos available',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            if (state.isSearching) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<PhotoBloc>().add(
                                    const ClearSearch(),
                                  );
                                },
                                child: const Text('Clear Search'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PhotoBloc>().add(const RefreshPhotos());
                        _scrollToTop(); // Scroll to top when refreshing
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(
                                AppConstants.smallPadding,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: state.photos.length,
                              itemBuilder: (context, index) {
                                final photo = state.photos[index];
                                return _buildPhotoCard(
                                  photo,
                                  key: ValueKey(photo.id),
                                );
                              },
                            ),
                          ),
                          // Number Pagination
                          if (state.totalPages > 1)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: NumberPagination(
                                currentPage: state.currentPage,
                                totalPages: state.totalPages,
                                onPageChanged: (page) {
                                  context.read<PhotoBloc>().add(GoToPage(page));
                                  _scrollToTop(); // Scroll to top when changing pages
                                },
                                // Customization
                                visiblePagesCount: 3,
                                fontSize: 14,
                                buttonElevation: 3,
                                buttonRadius: 12,
                                controlButtonSize: const Size(44, 44),
                                numberButtonSize: const Size(44, 44),
                                selectedButtonColor: Theme.of(
                                  context,
                                ).primaryColor,
                                unSelectedButtonColor: Colors.white,
                                controlButtonColor: Colors.white,
                                // Icons
                                firstPageIcon: Icon(
                                  Icons.first_page,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                previousPageIcon: Icon(
                                  Icons.chevron_left,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                nextPageIcon: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                lastPageIcon: Icon(
                                  Icons.last_page,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo, {Key? key}) {
    return _PhotoCardWidget(
      key: ValueKey(photo.id),
      photo: photo,
      onTap: () => _navigateToPhotoDetail(photo),
    );
  }
}

class _PhotoCardWidget extends StatefulWidget {
  final Photo photo;
  final VoidCallback onTap;

  const _PhotoCardWidget({super.key, required this.photo, required this.onTap});

  @override
  State<_PhotoCardWidget> createState() => _PhotoCardWidgetState();
}

class _PhotoCardWidgetState extends State<_PhotoCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: PreloadedImageWidget(
                  imageUrl: widget.photo.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Photo Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.photo.location,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF465052),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${widget.photo.createdBy}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

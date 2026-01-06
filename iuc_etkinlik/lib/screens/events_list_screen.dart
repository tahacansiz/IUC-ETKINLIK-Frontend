/// Events List Screen
/// Tüm etkinlikler listesi - arama ve filtreleme
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // İlk yükleme
    Future.microtask(() {
      final filter = ref.read(eventFilterProvider);
      ref.read(eventListProvider.notifier).loadEvents(
            categoryId: filter.categoryId,
            searchQuery: filter.searchQuery,
          );
    });

    // Infinite scroll için listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filter = ref.read(eventFilterProvider);
      ref.read(eventListProvider.notifier).loadMoreEvents(
            categoryId: filter.categoryId,
            searchQuery: filter.searchQuery,
          );
    }
  }

  void _onSearch(String query) {
    ref.read(eventFilterProvider.notifier).setSearchQuery(query);
    final filter = ref.read(eventFilterProvider);
    ref.read(eventListProvider.notifier).loadEvents(
          categoryId: filter.categoryId,
          searchQuery: query,
        );
  }

  @override
  Widget build(BuildContext context) {
    final eventListState = ref.watch(eventListProvider);
    final filterState = ref.watch(eventFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        actions: [
          // Filtre butonu
          IconButton(
            icon: Badge(
              isLabelVisible: filterState.hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SearchField(
              controller: _searchController,
              hint: 'Etkinlik ara...',
              onChanged: (value) {
                // Debounce için kısa bir gecikme
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _onSearch(value);
                  }
                });
              },
              onSubmitted: _onSearch,
              onClear: () {
                _onSearch('');
              },
            ),
          ),

          // Aktif filtreler
          if (filterState.hasActiveFilter)
            _buildActiveFilters(context, filterState),

          // Etkinlik listesi
          Expanded(
            child: _buildEventList(eventListState),
          ),
        ],
      ),
    );
  }

  /// Aktif filtreleri gösteren widget
  Widget _buildActiveFilters(BuildContext context, EventFilterState filter) {
    final categories = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Kategori filtresi
            if (filter.categoryId != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Chip(
                  label: Text(
                    categories.whenOrNull(
                          data: (cats) =>
                              cats
                                  .firstWhere((c) => c.id == filter.categoryId)
                                  .name,
                        ) ??
                        'Kategori',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    ref
                        .read(eventFilterProvider.notifier)
                        .setCategory(null);
                    ref.read(eventListProvider.notifier).loadEvents();
                  },
                ),
              ),

            // Arama filtresi
            if (filter.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Chip(
                  label: Text('"${filter.searchQuery}"'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                ),
              ),

            // Tümünü temizle
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(eventFilterProvider.notifier).clearFilters();
                ref.read(eventListProvider.notifier).loadEvents();
              },
              child: const Text('Temizle'),
            ),
          ],
        ),
      ),
    );
  }

  /// Etkinlik listesi widget'ı
  Widget _buildEventList(EventListState state) {
    if (state.isLoading && state.events.isEmpty) {
      // İlk yükleme
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: EventCardSkeleton(),
        ),
      );
    }

    if (state.errorMessage != null && state.events.isEmpty) {
      // Hata durumu
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () {
          final filter = ref.read(eventFilterProvider);
          ref.read(eventListProvider.notifier).loadEvents(
                categoryId: filter.categoryId,
                searchQuery: filter.searchQuery,
              );
        },
      );
    }

    if (state.events.isEmpty) {
      // Boş durum
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'Etkinlik Bulunamadı',
        message: 'Arama kriterlerinize uygun etkinlik bulunamadı.',
      );
    }

    // Etkinlik listesi
    return RefreshIndicator(
      onRefresh: () async {
        final filter = ref.read(eventFilterProvider);
        await ref.read(eventListProvider.notifier).refresh(
              categoryId: filter.categoryId,
              searchQuery: filter.searchQuery,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.events.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator for pagination
          if (index == state.events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final event = state.events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: EventCard(
              event: event,
              onTap: () => context.push('/events/${event.id}'),
            ),
          );
        },
      ),
    );
  }

  /// Filtre bottom sheet'i göster
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

/// Filtre Bottom Sheet
class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet();

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = ref.read(eventFilterProvider).categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrele',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedCategoryId = null);
                    },
                    child: const Text('Sıfırla'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kategori seçimi
              Text(
                'Kategori',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Expanded(
                child: categories.when(
                  data: (categoryList) {
                    return ListView(
                      controller: scrollController,
                      children: [
                        // Tüm kategoriler seçeneği
                        _CategoryFilterItem(
                          name: 'Tümü',
                          isSelected: _selectedCategoryId == null,
                          onTap: () {
                            setState(() => _selectedCategoryId = null);
                          },
                        ),
                        ...categoryList.map((category) {
                          return _CategoryFilterItem(
                            name: category.name,
                            colorHex: category.colorHex,
                            isSelected: _selectedCategoryId == category.id,
                            onTap: () {
                              setState(() => _selectedCategoryId = category.id);
                            },
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => const Center(
                    child: Text('Kategoriler yüklenemedi'),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Uygula butonu
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Uygula',
                  onPressed: () {
                    ref
                        .read(eventFilterProvider.notifier)
                        .setCategory(_selectedCategoryId);
                    ref.read(eventListProvider.notifier).loadEvents(
                          categoryId: _selectedCategoryId,
                          searchQuery: ref.read(eventFilterProvider).searchQuery,
                        );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kategori filtre item'ı
class _CategoryFilterItem extends StatelessWidget {
  final String name;
  final String? colorHex;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryFilterItem({
    required this.name,
    this.colorHex,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorHex != null
        ? ColorUtils.fromHex(colorHex!)
        : context.colorScheme.primary;

    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: colorHex != null ? color : Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(name),
      trailing: isSelected
          ? Icon(Icons.check, color: context.colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}

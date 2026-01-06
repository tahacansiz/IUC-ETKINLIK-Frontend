/// Home Screen (Dashboard)
/// Ana sayfa - Yaklaşan etkinlikler ve öne çıkanlar
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Bildirimleri yükle
    Future.microtask(() {
      ref.read(notificationListProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final featuredEvents = ref.watch(featuredEventsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Verileri yenile
          ref.invalidate(featuredEventsProvider);
          ref.invalidate(upcomingEventsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba, ${user?.fullName.split(' ').first ?? 'Misafir'}',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Bildirim butonu
                Consumer(
                  builder: (context, ref, child) {
                    final unreadCount =
                        ref.watch(unreadNotificationCountProvider);
                    return IconButtonWithBadge(
                      icon: Icons.notifications_outlined,
                      badgeCount: unreadCount,
                      onPressed: () => context.push('/notifications'),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),

            // İçerik
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Öne çıkan etkinlikler
                  _buildSectionTitle(
                    context,
                    'Öne Çıkan Etkinlikler',
                    icon: Icons.star_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeaturedEvents(featuredEvents),
                  const SizedBox(height: AppSpacing.xl),

                  // Yaklaşan etkinlikler
                  _buildSectionTitle(
                    context,
                    'Yaklaşan Etkinlikler',
                    icon: Icons.schedule,
                    actionText: 'Tümünü Gör',
                    onAction: () => context.go('/events'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildUpcomingEvents(upcomingEvents),
                  const SizedBox(height: AppSpacing.lg),

                  // Kategoriler
                  _buildSectionTitle(
                    context,
                    'Kategoriler',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategories(context),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bölüm başlığı widget'ı
  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 24,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionText),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  /// Öne çıkan etkinlikler widget'ı
  Widget _buildFeaturedEvents(AsyncValue<List<dynamic>> featuredEvents) {
    return featuredEvents.when(
      data: (events) {
        if (events.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('Öne çıkan etkinlik bulunamadı'),
            ),
          );
        }
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < events.length - 1 ? AppSpacing.md : 0,
                ),
                child: FeaturedEventCard(
                  event: event,
                  onTap: () => context.push('/events/${event.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
              width: 300,
              child: Card(
                child: Container(
                  color: context.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: AppSpacing.sm),
              Text('Yüklenirken hata oluştu'),
            ],
          ),
        ),
      ),
    );
  }

  /// Yaklaşan etkinlikler widget'ı
  Widget _buildUpcomingEvents(AsyncValue<List<dynamic>> upcomingEvents) {
    return upcomingEvents.when(
      data: (events) {
        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.event_busy,
            message: 'Yaklaşan etkinlik bulunamadı',
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length > 5 ? 5 : events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CompactEventCard(
                event: event,
                onTap: () => context.push('/events/${event.id}'),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: EventCardSkeleton(),
        ),
      ),
      error: (error, stack) => ErrorState(
        message: 'Etkinlikler yüklenirken hata oluştu',
        onRetry: () => ref.invalidate(upcomingEventsProvider),
      ),
    );
  }

  /// Kategoriler widget'ı
  Widget _buildCategories(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return categories.when(
      data: (categoryList) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.85,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            return _CategoryCard(
              name: category.name,
              colorHex: category.colorHex ?? '#1565C0',
              iconName: category.iconName ?? 'event',
              onTap: () {
                // Kategoriye göre filtrele
                ref
                    .read(eventFilterProvider.notifier)
                    .setCategory(category.id);
                context.go('/events');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

/// Kategori kartı widget'ı
class _CategoryCard extends StatelessWidget {
  final String name;
  final String colorHex;
  final String iconName;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.name,
    required this.colorHex,
    required this.iconName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(colorHex);

    // Icon mapping
    IconData getIcon() {
      switch (iconName) {
        case 'mic':
          return Icons.mic;
        case 'build':
          return Icons.build;
        case 'school':
          return Icons.school;
        case 'sports_soccer':
          return Icons.sports_soccer;
        case 'music_note':
          return Icons.music_note;
        case 'palette':
          return Icons.palette;
        case 'work':
          return Icons.work;
        case 'groups':
          return Icons.groups;
        default:
          return Icons.event;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              getIcon(),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

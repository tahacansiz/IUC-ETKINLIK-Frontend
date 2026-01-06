/// Event Detail Screen
/// Etkinlik detay sayfası
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final authState = ref.watch(authProvider);
    final hasJoined = ref.read(authProvider.notifier).hasJoinedEvent(widget.eventId);

    return Scaffold(
      body: eventAsync.when(
        loading: () => const LoadingState(message: 'Etkinlik yükleniyor...'),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(eventDetailProvider(widget.eventId));
          },
        ),
        data: (event) {
          if (event == null) {
            return const EmptyState(
              message: 'Etkinlik bulunamadı',
            );
          }
          return _buildContent(context, event, authState, hasJoined);
        },
      ),
      bottomNavigationBar: eventAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (event) {
          if (event == null || event.isPast) return null;
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildActionButton(context, event, authState, hasJoined),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EventModel event,
    AuthState authState,
    bool hasJoined,
  ) {
    return CustomScrollView(
      slivers: [
        // Sliver App Bar with image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white),
              ),
              onPressed: () {
                context.showSnackBar('Paylaşım özelliği yakında eklenecek');
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Görsel
                if (event.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: context.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.event, size: 64),
                    ),
                  )
                else
                  Container(
                    color: context.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.event, size: 64),
                  ),

                // Gradient overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),

                // Kategori badge
                if (event.category != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorUtils.fromHex(
                          event.category!.colorHex ?? '#1565C0',
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        event.category!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Başlık
              Text(
                event.title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Organizatör
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: context.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.group,
                      size: 18,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    event.organizerName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Bilgi kartları
              _buildInfoCard(
                context,
                icon: Icons.calendar_today,
                iconColor: context.colorScheme.primary,
                title: 'Tarih ve Saat',
                content: DateTimeUtils.formatDateTime(event.dateTime),
                subtitle: DateTimeUtils.getDayName(event.dateTime),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInfoCard(
                context,
                icon: Icons.location_on,
                iconColor: AppColors.secondary,
                title: 'Konum',
                content: event.location,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInfoCard(
                context,
                icon: Icons.people,
                iconColor: AppColors.tertiary,
                title: 'Katılımcı',
                content: '${event.currentParticipants} / ${event.maxParticipants}',
                subtitle: event.isFull
                    ? 'Kontenjan dolu'
                    : '${event.remainingSlots} kişilik yer var',
                trailing: SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: event.occupancyRate / 100,
                    backgroundColor: context.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      event.occupancyRate > 90
                          ? context.colorScheme.error
                          : event.occupancyRate > 70
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Açıklama
              Text(
                'Açıklama',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                event.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Durum bilgisi
              if (event.isPast)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.grey),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Bu etkinlik sona erdi',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 100), // Bottom padding for FAB
            ]),
          ),
        ),
      ],
    );
  }

  /// Bilgi kartı widget'ı
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  content,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    EventModel event,
    AuthState authState,
    bool hasJoined,
  ) {
    // Dolu kontrolü
    if (event.isFull && !hasJoined) {
      return AppButton(
        text: 'Kontenjan Dolu',
        isFullWidth: true,
        onPressed: null,
        type: AppButtonType.secondary,
      );
    }

    // Katıl / Ayrıl butonu
    if (hasJoined) {
      return AppButton(
        text: 'Katılımı İptal Et',
        isFullWidth: true,
        isLoading: _isJoining,
        type: AppButtonType.outlined,
        icon: Icons.close,
        onPressed: () async {
          setState(() => _isJoining = true);
          
          final eventService = ref.read(eventServiceProvider);
          final result = await eventService.leaveEvent(
            widget.eventId,
            authState.user!.id,
          );

          if (!mounted) return;
          setState(() => _isJoining = false);

          if (result.success) {
            ref.read(authProvider.notifier).removeJoinedEvent(widget.eventId);
            ref.invalidate(eventDetailProvider(widget.eventId));
            _showSnackBar('Katılımınız iptal edildi');
          }
        },
      );
    }

    return GradientButton(
      text: 'Etkinliğe Katıl',
      isLoading: _isJoining,
      onPressed: () async {
        if (!authState.isAuthenticated) {
          _showSnackBar('Katılmak için giriş yapmalısınız', isError: true);
          return;
        }

        setState(() => _isJoining = true);

        final eventService = ref.read(eventServiceProvider);
        final result = await eventService.joinEvent(
          widget.eventId,
          authState.user!.id,
        );

        if (!mounted) return;
        setState(() => _isJoining = false);

        if (result.success) {
          ref.read(authProvider.notifier).addJoinedEvent(widget.eventId);
          ref.invalidate(eventDetailProvider(widget.eventId));
          _showSnackBar('Etkinliğe başarıyla katıldınız!');
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    context.showSnackBar(message, isError: isError);
  }
}

/// Profile Screen
/// Kullanıcı profil sayfası
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../services/services.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          message: 'Profil bilgileri yüklenemedi',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.showSnackBar('Ayarlar yakında eklenecek');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profil başlığı
            _buildProfileHeader(context, user),
            const SizedBox(height: AppSpacing.xl),

            // Rol badge'i
            _buildRoleBadge(context, user),
            const SizedBox(height: AppSpacing.xl),

            // İstatistikler
            _buildStats(context, user),
            const SizedBox(height: AppSpacing.xl),

            // Katıldığım etkinlikler
            _buildJoinedEventsSection(context, ref, user),
            const SizedBox(height: AppSpacing.xl),

            // Menü öğeleri
            _buildMenuItems(context, ref),
          ],
        ),
      ),
    );
  }

  /// Profil başlığı
  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: context.colorScheme.primaryContainer,
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                  style: context.textTheme.displaySmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.md),

        // İsim
        Text(
          user.fullName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Email
        Text(
          user.email,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Rol badge'i
  Widget _buildRoleBadge(BuildContext context, user) {
    final isAdmin = user.role.name == 'clubAdmin';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.secondary.withValues(alpha: 0.15)
            : context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isAdmin ? AppColors.secondary : context.colorScheme.primary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.school,
            size: 20,
            color: isAdmin ? AppColors.secondary : context.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            user.role.displayName,
            style: context.textTheme.labelLarge?.copyWith(
              color:
                  isAdmin ? AppColors.secondary : context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistikler
  Widget _buildStats(BuildContext context, user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'Katıldığım',
          value: user.joinedEventIds.length.toString(),
          icon: Icons.event_available,
        ),
        Container(
          width: 1,
          height: 40,
          color: context.colorScheme.outline,
        ),
        _StatItem(
          label: 'Üyelik',
          value: _getMembershipDuration(user.createdAt),
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  String _getMembershipDuration(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays < 30) return '${diff.inDays} gün';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ay';
    return '${(diff.inDays / 365).floor()} yıl';
  }

  /// Katıldığım etkinlikler bölümü
  Widget _buildJoinedEventsSection(BuildContext context, WidgetRef ref, user) {
    if (user.joinedEventIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Katıldığım Etkinlikler',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Tüm katıldığım etkinlikleri göster
                context.showSnackBar('Tüm etkinlikler sayfası yakında');
              },
              child: const Text('Tümü'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Etkinlik listesi (ilk 3)
        ...user.joinedEventIds.take(3).map((eventId) {
          final event = MockEvents.findById(eventId);
          if (event == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: CompactEventCard(
              event: event,
              onTap: () => context.push('/events/$eventId'),
            ),
          );
        }),
      ],
    );
  }

  /// Menü öğeleri
  Widget _buildMenuItems(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.notifications_outlined,
          title: 'Bildirim Ayarları',
          onTap: () {
            context.showSnackBar('Bildirim ayarları yakında');
          },
        ),
        _MenuItem(
          icon: Icons.help_outline,
          title: 'Yardım & Destek',
          onTap: () {
            context.showSnackBar('Yardım sayfası yakında');
          },
        ),
        _MenuItem(
          icon: Icons.info_outline,
          title: 'Hakkında',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'İÜC Etkinlik',
              applicationVersion: '1.0.0',
              applicationIcon: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                ),
              ),
              children: [
                const Text(
                  'İstanbul Üniversitesi-Cerrahpaşa etkinlik yönetim uygulaması.',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        _MenuItem(
          icon: Icons.logout,
          title: 'Çıkış Yap',
          isDestructive: true,
          onTap: () async {
            // Çıkış onay dialogu
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Çıkış Yap'),
                content: const Text(
                  'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                    child: const Text('Çıkış Yap'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            }
          },
        ),
      ],
    );
  }
}

/// İstatistik item'ı
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: context.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Menü item'ı
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? context.colorScheme.error : context.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

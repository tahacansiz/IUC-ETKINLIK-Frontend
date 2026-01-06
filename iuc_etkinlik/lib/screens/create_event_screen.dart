/// Create Event Screen
/// Yeni etkinlik oluşturma ekranı (Sadece Club Admin için)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controller'ları
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '100');

  // Seçilen değerler
  DateTime? _selectedDateTime;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      context.showSnackBar('Lütfen tarih ve saat seçin', isError: true);
      return;
    }

    if (_selectedCategoryId == null) {
      context.showSnackBar('Lütfen kategori seçin', isError: true);
      return;
    }

    final success = await ref.read(createEventProvider.notifier).createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: _selectedDateTime!,
          location: _locationController.text.trim(),
          categoryId: _selectedCategoryId!,
          maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 100,
        );

    if (success && mounted) {
      context.showSnackBar('Etkinlik başarıyla oluşturuldu!');
      // Event listesini yenile
      ref.invalidate(featuredEventsProvider);
      ref.invalidate(upcomingEventsProvider);
      ref.read(eventListProvider.notifier).refresh();
      // Ana sayfaya dön
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createEventProvider);
    final isClubAdmin = ref.watch(isClubAdminProvider);
    final categories = ref.watch(categoriesProvider);

    // Club Admin değilse erişim engelle
    if (!isClubAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Etkinlik Oluştur')),
        body: const EmptyState(
          icon: Icons.lock_outlined,
          title: 'Erişim Engellendi',
          message: 'Etkinlik oluşturmak için Kulüp Admin yetkisine sahip olmalısınız.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Etkinlik'),
        actions: [
          // Kaydet butonu
          TextButton(
            onPressed: createState.isLoading ? null : _handleSubmit,
            child: createState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etkinlik başlığı
              AppTextField(
                label: 'Etkinlik Başlığı',
                hint: 'Etkinlik adını girin',
                controller: _titleController,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                validator: (value) =>
                    ValidationUtils.validateRequired(value, 'Başlık'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Açıklama
              AppTextField(
                label: 'Açıklama',
                hint: 'Etkinlik hakkında detaylı bilgi verin',
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                validator: ValidationUtils.validateDescription,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tarih ve Saat
              DateTimePickerField(
                label: 'Tarih ve Saat',
                value: _selectedDateTime,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onChanged: (dateTime) {
                  setState(() => _selectedDateTime = dateTime);
                },
                errorText:
                    _selectedDateTime == null && _formKey.currentState?.validate() == false
                        ? 'Tarih seçimi gerekli'
                        : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Konum
              AppTextField(
                label: 'Konum',
                hint: 'Etkinlik yeri',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    ValidationUtils.validateRequired(value, 'Konum'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kategori seçimi
              Text(
                'Kategori',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              categories.when(
                data: (categoryList) => _buildCategorySelector(categoryList),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Text('Kategoriler yüklenemedi'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Maksimum katılımcı sayısı
              AppTextField(
                label: 'Maksimum Katılımcı Sayısı',
                hint: '100',
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.people_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Katılımcı sayısı gerekli';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Hata mesajı
              if (createState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          createState.errorMessage!,
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),

              // Oluştur butonu
              GradientButton(
                text: 'Etkinlik Oluştur',
                isLoading: createState.isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: AppSpacing.lg),

              // İpucu
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Etkinlik oluşturulduktan sonra tüm kullanıcılar tarafından görülebilir olacaktır.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori seçici widget'ı
  Widget _buildCategorySelector(List<CategoryModel> categories) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: categories.map((category) {
        final isSelected = _selectedCategoryId == category.id;
        final color = ColorUtils.fromHex(category.colorHex ?? '#1565C0');

        return FilterChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategoryId = selected ? category.id : null;
            });
          },
          backgroundColor: context.colorScheme.surfaceContainerHighest,
          selectedColor: color.withValues(alpha: 0.2),
          checkmarkColor: color,
          labelStyle: TextStyle(
            color: isSelected ? color : context.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? color : context.colorScheme.outline,
          ),
        );
      }).toList(),
    );
  }
}

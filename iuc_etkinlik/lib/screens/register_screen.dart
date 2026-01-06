/// Register Screen
/// Kullanıcı kayıt ekranı
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Seçili rol
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Kayıt işlemi
  Future<void> _handleRegister() async {
    // Form validasyonunu kontrol et
    if (!_formKey.currentState!.validate()) return;

    // Şifre eşleşme kontrolü
    if (_passwordController.text != _confirmPasswordController.text) {
      context.showSnackBar('Şifreler eşleşmiyor', isError: true);
      return;
    }

    // Auth provider'ı kullanarak kayıt ol
    final success = await ref.read(authProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (success && mounted) {
      // Başarılı kayıt - ana sayfaya yönlendir
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth state'i dinle
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                Text(
                  'Hesap Oluştur',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Etkinliklere katılmak için kayıt ol',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Ad Soyad
                AppTextField(
                  label: 'Ad Soyad',
                  hint: 'Adınız ve soyadınız',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person_outlined,
                  enabled: !isLoading,
                  validator: ValidationUtils.validateName,
                ),
                const SizedBox(height: AppSpacing.md),

                // Email
                AppTextField(
                  label: 'Email',
                  hint: 'ornek@iuc.edu.tr',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  enabled: !isLoading,
                  validator: ValidationUtils.validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),

                // Şifre
                AppTextField(
                  label: 'Şifre',
                  hint: 'En az 6 karakter',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outlined,
                  enabled: !isLoading,
                  validator: ValidationUtils.validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),

                // Şifre tekrar
                AppTextField(
                  label: 'Şifre Tekrar',
                  hint: 'Şifrenizi tekrar girin',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outlined,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return ValidationUtils.validatePassword(value);
                  },
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Rol seçimi
                _buildRoleSelector(context, isLoading),
                const SizedBox(height: AppSpacing.lg),

                // Hata mesajı
                if (authState.status == AuthStatus.error &&
                    authState.errorMessage != null)
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
                            authState.errorMessage!,
                            style: TextStyle(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Kayıt butonu
                GradientButton(
                  text: 'Kayıt Ol',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Giriş yap linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabınız var mı? ',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rol seçici widget'ı
  Widget _buildRoleSelector(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Türü',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Öğrenci seçeneği
            Expanded(
              child: _RoleCard(
                role: UserRole.student,
                isSelected: _selectedRole == UserRole.student,
                isEnabled: !isLoading,
                onTap: () {
                  setState(() => _selectedRole = UserRole.student);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Kulüp Admin seçeneği
            Expanded(
              child: _RoleCard(
                role: UserRole.clubAdmin,
                isSelected: _selectedRole == UserRole.clubAdmin,
                isEnabled: !isLoading,
                onTap: () {
                  setState(() => _selectedRole = UserRole.clubAdmin);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Rol seçim kartı widget'ı
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Rol'e göre icon ve açıklama
    final IconData icon;
    final String description;
    switch (role) {
      case UserRole.student:
        icon = Icons.school_outlined;
        description = 'Etkinliklere katıl';
        break;
      case UserRole.clubAdmin:
        icon = Icons.admin_panel_settings_outlined;
        description = 'Etkinlik oluştur ve yönet';
        break;
    }

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              role.displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

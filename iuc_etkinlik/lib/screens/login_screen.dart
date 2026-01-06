/// Login Screen
/// Kullanıcı giriş ekranı
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form key - form validasyonu için
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus node'lar
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Giriş işlemi
  Future<void> _handleLogin() async {
    // Form validasyonunu kontrol et
    if (!_formKey.currentState!.validate()) return;

    // Auth provider'ı kullanarak giriş yap
    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      // Başarılı giriş - ana sayfaya yönlendir
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth state'i dinle
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ve başlık
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xxl),

                  // Email alanı
                  AppTextField(
                    label: 'Email',
                    hint: 'ornek@iuc.edu.tr',
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    enabled: !isLoading,
                    validator: ValidationUtils.validateEmail,
                    onSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Şifre alanı
                  AppTextField(
                    label: 'Şifre',
                    hint: 'Şifrenizi girin',
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outlined,
                    enabled: !isLoading,
                    validator: ValidationUtils.validatePassword,
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Şifremi unuttum linki
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Şifremi unuttum sayfasına yönlendir
                              context.showSnackBar(
                                  'Şifre sıfırlama özelliği yakında eklenecek');
                            },
                      child: const Text('Şifremi Unuttum'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Hata mesajı
                  if (authState.status == AuthStatus.error &&
                      authState.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.lg),

                  // Giriş butonu
                  GradientButton(
                    text: 'Giriş Yap',
                    isLoading: isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Kayıt ol linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu? ',
                        style: TextStyle(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push('/register'),
                        child: const Text('Kayıt Ol'),
                      ),
                    ],
                  ),

                  // Demo giriş bilgileri (development için)
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDemoCredentials(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Başlık bölümü
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo placeholder
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.event,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Uygulama adı
        Text(
          'İÜC Etkinlik',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Alt başlık
        Text(
          'Kampüsteki etkinlikleri keşfet',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Demo giriş bilgileri (development için)
  Widget _buildDemoCredentials(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Demo Giriş Bilgileri',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Öğrenci: ahmet@stu.iuc.edu.tr / 123456',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kulüp Admin: elif@iuc.edu.tr / 123456',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

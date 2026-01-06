/// IUC Etkinlik - Üniversite Etkinlik Yönetim Uygulaması
/// Ana giriş noktası ve router yapılandırması
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/core.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: IUCEtkinlikApp()));
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      
      // Kullanıcı giriş yapmamışsa ve giriş/kayıt sayfasında değilse
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }
      
      // Kullanıcı giriş yapmışsa ve giriş/kayıt sayfasındaysa
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsListScreen(),
          ),
          GoRoute(
            path: '/create-event',
            name: 'createEvent',
            builder: (context, state) => const CreateEventScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Detail routes (outside shell)
      GoRoute(
        path: '/events/:id',
        name: 'eventDetail',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Ana uygulama widget'ı
class IUCEtkinlikApp extends ConsumerWidget {
  const IUCEtkinlikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

/// Ana shell - Bottom navigation bar içerir
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClubAdmin = ref.watch(isClubAdminProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context, isClubAdmin),
        onDestinationSelected: (index) => _onItemTapped(index, context, isClubAdmin),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Etkinlikler',
          ),
          if (isClubAdmin)
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Oluştur',
            ),
          NavigationDestination(
            icon: unreadCount > 0
                ? Badge(
                    label: Text(unreadCount > 9 ? '9+' : unreadCount.toString()),
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            selectedIcon: unreadCount > 0
                ? Badge(
                    label: Text(unreadCount > 9 ? '9+' : unreadCount.toString()),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: 'Bildirimler',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool isClubAdmin) {
    final location = GoRouterState.of(context).matchedLocation;
    
    if (location.startsWith('/events')) {
      return 1;
    }
    if (location == '/create-event') {
      return isClubAdmin ? 2 : 0;
    }
    if (location == '/notifications') {
      return isClubAdmin ? 3 : 2;
    }
    if (location == '/profile') {
      return isClubAdmin ? 4 : 3;
    }
    return 0; // home
  }

  void _onItemTapped(int index, BuildContext context, bool isClubAdmin) {
    if (isClubAdmin) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/events');
          break;
        case 2:
          context.go('/create-event');
          break;
        case 3:
          context.go('/notifications');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } else {
      // Club admin değilse (student), create-event yok
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/events');
          break;
        case 2:
          context.go('/notifications');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }
  }
}


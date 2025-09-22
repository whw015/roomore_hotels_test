import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/favorite_item.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../theme/app_colors.dart';
import '../cubits/app_flow/app_flow_cubit.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import 'language_selection_screen.dart';
import 'login_register_screen.dart';
import 'profile_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = context.watch<HomeCubit>().state;
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;
    final greeting = _greetingFor(context, state);
    final headerSubtitle = _headerSubtitle(context);
    final cartLabel = _localizedOrFallback('home.actions.cart', 'Cart');
    final notificationsLabel = _localizedOrFallback(
      'home.actions.notifications',
      'Notifications',
    );
    final bookingsLabel = _localizedOrFallback(
      'home.sections.my_bookings',
      'Bookings',
    );
    final searchHint = _localizedOrFallback(
      'home.search_hint',
      'Search for a service',
    );
    final searchActionLabel = _localizedOrFallback(
      'home.search_tap',
      searchHint,
    );

    return Scaffold(
      drawer: _HomeDrawer(
        user: user,
        displayName: _displayNameOf(state),
        onProfileTap: () => _openProfile(context),
        onSupportTap: () => _openSupport(context),
        onLanguageTap: () => _openLanguage(context),
        onLogout: () => _handleLogout(context),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(
              controller: _codeController,
              greeting: greeting,
              subtitle: headerSubtitle,
              user: user,
              initials: _initialsOf(state),
              cartLabel: cartLabel,
              notificationsLabel: notificationsLabel,
              bookingsLabel: bookingsLabel,
              searchHint: searchHint,
              onCartTap: () => _showComingSoon(context, cartLabel),
              onNotificationsTap: () =>
                  _showComingSoon(context, notificationsLabel),
              onBookingsTap: () => _showComingSoon(context, bookingsLabel),
              onSearchTap: () => _showComingSoon(context, searchActionLabel),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: tr('nav.orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: tr('nav.favorites'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();
    final flowCubit = context.read<AppFlowCubit>();
    final navigator = Navigator.of(context);
    await authRepository.signOut();
    await flowCubit.refreshFlow();
    navigator.pushNamedAndRemoveUntil(
      LoginRegisterScreen.routeName,
      (route) => false,
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openSupport(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
  }

  void _openLanguage(BuildContext context) {
    Navigator.of(context).pushNamed(LanguageSelectionScreen.routeName);
  }

  String _headerSubtitle(BuildContext context) {
    final value = tr('home.messages.footer');
    if (value != 'home.messages.footer') {
      return value;
    }
    return 'We wish you a pleasant stay';
  }

  String _localizedOrFallback(
    String key,
    String fallback, {
    Map<String, String>? namedArgs,
  }) {
    final value = tr(key, namedArgs: namedArgs);
    if (value == key) {
      if (namedArgs == null || namedArgs.isEmpty) {
        return fallback;
      }
      var resolved = fallback;
      namedArgs.forEach((placeholder, replacement) {
        resolved = resolved.replaceAll('{$placeholder}', replacement);
      });
      return resolved;
    }
    return value;
  }

  String _greetingFor(BuildContext context, HomeState state) {
    final placeholder = tr('home.guest_placeholder');
    final first = state.firstName.isNotEmpty
        ? state.firstName
        : (placeholder == 'home.guest_placeholder' ? 'Guest' : placeholder);
    final last = state.lastName.trim();
    final fullName = [
      first,
      last,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    final nameForGreeting = fullName.isEmpty ? first : fullName;
    final key = 'home.greeting_basic_full';
    final translated = tr(key, namedArgs: {'name': nameForGreeting});
    if (translated != key) {
      return translated;
    }

    return 'Welcome $nameForGreeting.';
  }

  String _displayNameOf(HomeState state) {
    if (state.firstName.isEmpty && state.lastName.isEmpty) {
      final placeholder = tr('home.guest_placeholder');
      return placeholder == 'home.guest_placeholder' ? 'Guest' : placeholder;
    }
    return [
      state.firstName,
      state.lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
  }

  String _initialsOf(HomeState state) {
    final name = _displayNameOf(state);
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map(_firstLetter).join();
  }

  void _showComingSoon(BuildContext context, String label) {
    final message = '$label آ· ${tr('common.coming_soon')}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.controller,
    required this.greeting,
    required this.subtitle,
    required this.user,
    required this.initials,
    required this.cartLabel,
    required this.notificationsLabel,
    required this.bookingsLabel,
    required this.searchHint,
    required this.onCartTap,
    required this.onNotificationsTap,
    required this.onBookingsTap,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final String greeting;
  final String subtitle;
  final User? user;
  final String initials;
  final String cartLabel;
  final String notificationsLabel;
  final String bookingsLabel;
  final String searchHint;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          _HomeHeader(
            greeting: greeting,
            subtitle: subtitle,
            user: user,
            initials: initials,
            cartLabel: cartLabel,
            notificationsLabel: notificationsLabel,
            bookingsLabel: bookingsLabel,
            searchHint: searchHint,
            onCartTap: onCartTap,
            onNotificationsTap: onNotificationsTap,
            onBookingsTap: onBookingsTap,
            onSearchTap: onSearchTap,
            topInset: padding.top,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.subtitle,
    required this.user,
    required this.initials,
    required this.cartLabel,
    required this.notificationsLabel,
    required this.bookingsLabel,
    required this.searchHint,
    required this.onCartTap,
    required this.onNotificationsTap,
    required this.onBookingsTap,
    required this.onSearchTap,
    required this.topInset,
  });

  final String greeting;
  final String subtitle;
  final User? user;
  final String initials;
  final String cartLabel;
  final String notificationsLabel;
  final String bookingsLabel;
  final String searchHint;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onSearchTap;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final onPrimary = AppColors.bg;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(10, topInset + 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _HomeAvatar(
                          user: user,
                          initials: initials,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 20,
                              color: onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.shopping_cart_outlined,
                tooltip: cartLabel,
                onPressed: onCartTap,
              ),
              const SizedBox(width: 12),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: notificationsLabel,
                onPressed: onNotificationsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.15),
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}

extension BuildContextLocalization on BuildContext {
  String localizedOrFallback({
    required String key,
    required String fallback,
    Map<String, String>? namedArgs,
  }) {
    final value = tr(key, namedArgs: namedArgs);
    if (value == key) {
      if (namedArgs == null || namedArgs.isEmpty) {
        return fallback;
      }
      var resolved = fallback;
      namedArgs.forEach((placeholder, replacement) {
        resolved = resolved.replaceAll('{$placeholder}', replacement);
      });
      return resolved;
    }
    return value;
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.user, required this.initials, this.padding});

  final User? user;
  final String initials;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = colorScheme.onPrimary.withValues(alpha: 0.2);
    final photoUrl = (user?.photoURL ?? '').trim();
    final hasPhoto = photoUrl.isNotEmpty;
    final effectivePadding =
        padding ?? const EdgeInsetsDirectional.only(start: 16);

    return Padding(
      padding: effectivePadding,
      child: GestureDetector(
        onTap: () {
          final scaffoldState = Scaffold.maybeOf(context);
          if (scaffoldState?.hasDrawer ?? false) {
            scaffoldState!.openDrawer();
          }
        },
        child: CircleAvatar(
          backgroundColor: background,
          backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
          child: hasPhoto
              ? null
              : Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.user,
    required this.displayName,
    required this.onProfileTap,
    required this.onSupportTap,
    required this.onLanguageTap,
    required this.onLogout,
  });

  final User? user;
  final String displayName;
  final VoidCallback onProfileTap;
  final VoidCallback onSupportTap;
  final VoidCallback onLanguageTap;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final email = user?.email;
    final photoUrl = (user?.photoURL ?? '').trim();
    final hasPhoto = photoUrl.isNotEmpty;

    return Drawer(
      child: SafeArea(
        child: ListTileTheme(
          iconColor: colorScheme.primary,
          textColor: colorScheme.onSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: colorScheme.primary),
                accountName: Text(displayName),
                accountEmail: email != null ? Text(email) : null,
                currentAccountPicture: CircleAvatar(
                  backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          _initialsFromName(displayName),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(tr('nav.profile')),
                onTap: () {
                  Navigator.of(context).pop();
                  onProfileTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(tr('logout')),
                onTap: () async {
                  Navigator.of(context).pop();
                  await onLogout();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.headset_mic_outlined),
                title: Text(tr('home.actions.support')),
                onTap: () {
                  Navigator.of(context).pop();
                  onSupportTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(tr('home.actions.change_language')),
                onTap: () {
                  Navigator.of(context).pop();
                  onLanguageTap();
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  tr('home.messages.footer'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initialsFromName(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    return parts.take(2).map(_firstLetter).join();
  }
}

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({
    required this.repository,
    required this.userId,
    super.key,
  });

  final HomeRepository repository;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FavoriteItem>>(
      stream: repository.watchFavorites(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final favorites = snapshot.data ?? const [];
        if (favorites.isEmpty) {
          return _CenteredMessage(tr('home.favorites.empty'));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showComingSoon(context, item.title),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Ink.image(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                              child: const SizedBox.expand(),
                            )
                          : Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08),
                              child: const Center(
                                child: Icon(Icons.favorite_border, size: 32),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.category,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFC107),
                              ),
                              const SizedBox(width: 4),
                              Text(item.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    final message = '$title آ· ${tr('common.coming_soon')}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _firstLetter(String value) {
  if (value.isEmpty) {
    return '';
  }
  final iterator = value.runes.iterator;
  if (!iterator.moveNext()) {
    return '';
  }
  return String.fromCharCode(iterator.current).toUpperCase();
}

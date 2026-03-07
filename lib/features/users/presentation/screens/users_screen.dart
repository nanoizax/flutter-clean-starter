// Users screen — Leandro Perez — SonhoLab
// Paginated list with pull-to-refresh, infinite scroll, and logout action.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_clean_starter/core/router/app_router.dart';
import 'package:flutter_clean_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';
import 'package:flutter_clean_starter/features/users/presentation/providers/users_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial load after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).fetchUsers(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(usersProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref.read(usersProvider.notifier).fetchUsers();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: _logout,
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.users.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(usersProvider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(usersProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            // Loading indicator at the bottom during pagination.
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _UserTile(user: state.users[index]);
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final UserListItem user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          user.initials,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.goNamed(
          AppRoutes.userDetail,
          pathParameters: {'id': user.id.toString()},
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

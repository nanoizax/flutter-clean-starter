// UserDetail screen — Leandro Perez — SonhoLab
// Displays full details for a single user loaded via FutureProvider.family.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';
import 'package:flutter_clean_starter/features/users/presentation/providers/users_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('User Detail')),
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorBody(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.refresh(userDetailProvider(userId)),
        ),
        data: (user) => _UserDetailBody(user: user),
      ),
    );
  }
}

class _UserDetailBody extends StatelessWidget {
  const _UserDetailBody({required this.user});

  final UserListItem user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Center(
            child: CircleAvatar(
              radius: 52,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                user.initials,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (user.username != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '@${user.username}',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // ── Info card ─────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  if (user.phone != null)
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phone!,
                    ),
                  if (user.website != null)
                    _InfoTile(
                      icon: Icons.language_outlined,
                      label: 'Website',
                      value: user.website!,
                    ),
                  if (user.city != null)
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'City',
                      value: user.city!,
                    ),
                  if (user.companyName != null)
                    _InfoTile(
                      icon: Icons.business_outlined,
                      label: 'Company',
                      value: user.companyName!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      subtitle: Text(value),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

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
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

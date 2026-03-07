// Users provider — Leandro Perez — SonhoLab
// Riverpod StateNotifier for paginated user list + single user detail.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_clean_starter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_clean_starter/features/users/data/datasources/users_remote_datasource.dart';
import 'package:flutter_clean_starter/features/users/data/repositories/users_repository_impl.dart';
import 'package:flutter_clean_starter/features/users/domain/entities/user_list_item.dart';
import 'package:flutter_clean_starter/features/users/domain/repositories/users_repository.dart';
import 'package:flutter_clean_starter/features/users/domain/usecases/get_users_usecase.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSourceImpl(client: ref.watch(dioClientProvider));
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(
    remoteDataSource: ref.watch(usersRemoteDataSourceProvider),
  );
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(repository: ref.watch(usersRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Users list state
// ---------------------------------------------------------------------------

class UsersState {
  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<UserListItem> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  bool get hasError => errorMessage != null;

  UsersState copyWith({
    List<UserListItem>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier({required this.getUsersUseCase}) : super(const UsersState());

  final GetUsersUseCase getUsersUseCase;

  static const int _pageSize = 20;

  Future<void> fetchUsers({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (refresh) {
      state = const UsersState(isLoading: true);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    final page = refresh ? 1 : state.currentPage;
    final result = await getUsersUseCase(GetUsersParams(page: page, limit: _pageSize));

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (newUsers) {
        final allUsers = refresh ? newUsers : [...state.users, ...newUsers];
        state = state.copyWith(
          users: allUsers,
          isLoading: false,
          isLoadingMore: false,
          currentPage: page + 1,
          hasMore: newUsers.length >= _pageSize,
          clearError: true,
        );
      },
    );
  }

  Future<void> refresh() => fetchUsers(refresh: true);
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(getUsersUseCase: ref.watch(getUsersUseCaseProvider));
});

// ---------------------------------------------------------------------------
// Single user detail
// ---------------------------------------------------------------------------

final userDetailProvider =
    FutureProvider.family<UserListItem, int>((ref, id) async {
  final repository = ref.watch(usersRepositoryProvider);
  final result = await repository.getUserById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

# flutter-clean-starter

**Leandro Perez — SonhoLab**

Production-ready Flutter starter template built on Clean Architecture, with Riverpod, Dio, Go Router, and Isar.

---

## Stack

| Layer | Technology |
|---|---|
| State management | Riverpod 2 (StateNotifier + FutureProvider) |
| HTTP client | Dio 5 with interceptors |
| Routing | Go Router 14 (auth-guard redirect) |
| Local DB | Isar 3 |
| Persistence | shared\_preferences |
| Code gen | build\_runner, freezed, json\_serializable, isar\_generator |
| Testing | flutter\_test + mocktail |
| Linting | flutter\_lints |

---

## Architecture

Three-layer Clean Architecture per feature:

```
feature/
├── data/          # Datasources, Models (JSON ↔ domain), Repository impl
├── domain/        # Entities, Repository contracts, Use-cases
└── presentation/  # Riverpod providers, Screens, Widgets
```

Error handling uses a custom `Either<Failure, T>` with no external dependencies.
Failures are sealed classes: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `AuthFailure`.

---

## Route tree

```
/splash           → SplashScreen   (auth check)
/login            → LoginScreen
/home/users       → UsersScreen    (paginated list)
/home/users/:id   → UserDetailScreen
```

Auth guard in `AppRouter.redirect` — unauthenticated users are always redirected to `/login`.

---

## Getting started

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed / json_serializable / riverpod_generator / isar)
dart run build_runner build --delete-conflicting-outputs

# Run on device / emulator
flutter run --dart-define=BASE_URL=https://your-api.example.com

# Run all tests
flutter test

# Lint
flutter analyze
```

### Demo mode (JSONPlaceholder)

The default `BASE_URL` is `https://jsonplaceholder.typicode.com`.
The Users feature works out of the box with this API.
Login will fail against JSONPlaceholder — set `BASE_URL` to a real auth endpoint.

---

## Database (local dev API)

Start a local PostgreSQL instance for backend development:

```bash
docker compose up -d
```

Connects on `localhost:5432` with credentials `starter / starter_secret / starter_db`.

---

## Code generation

Any time you add a `@freezed`, `@JsonSerializable`, `@riverpod`, or `@Collection` annotation, re-run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Project structure

```
lib/
├── core/
│   ├── error/          # Exceptions + Failures (sealed)
│   ├── network/        # DioClient + ApiEndpoints
│   ├── router/         # AppRouter (GoRouter)
│   ├── theme/          # AppTheme (Material 3)
│   └── utils/          # Either<L,R>
└── features/
    ├── auth/           # Login, Logout, session management
    └── users/          # Paginated user list + detail
```

---

## Environment variables

Pass at build / run time via `--dart-define`:

| Key | Default | Description |
|---|---|---|
| `BASE_URL` | `https://jsonplaceholder.typicode.com` | Backend API base URL |

---

## License

MIT — Leandro Perez / SonhoLab

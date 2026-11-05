# playx_core example

A small app using `PlayxPrefs` (persisted counter) and `PlayxEnv` (configuration). Tap the tune icon in the app bar to see everything `PlayxEnv` loaded.

## Environment files

| File | Purpose |
| --- | --- |
| `.env` | Normal config, bundled as a plain asset. |
| `.env.dev`, `.env.prod` | Loaded after `.env` for that environment, overriding its values. |
| `.env.secrets` | Sensitive values, encrypted into `lib/generated/playx_secure_env.g.dart`. |

The env files are declared under `flutter: assets:` in `pubspec.yaml`. `.env.secrets` is not an asset: only its encrypted, generated Dart file ships with the app.

> **Demo only:** this example commits `.env.secrets` and the generated file so it runs out of the box. In a real app, add `.env.secrets*`, `.playx_secure_env.key` and `lib/generated/playx_secure_env.g.dart` to `.gitignore`.

## Run

```sh
flutter run                                   # .env only
flutter run --dart-define=PLAYX_ENV=dev       # .env + .env.dev (dark theme)
flutter run --dart-define=PLAYX_ENV=prod      # .env + .env.prod
```

Override values at build time:

```sh
# Any values, without declaring them in code:
flutter run --dart-define=PLAYX_DEFINES="ENABLE_LOGS=false;THEME_MODE=dark"

# A value declared in main.dart's `dartDefines`:
flutter run --dart-define=APP_NAME="My Demo"
```

## Secure env

After editing `.env.secrets`, regenerate the encrypted file:

```sh
dart run playx_core:secure_env
```

In CI, the values can come from environment variables instead of the file:

```sh
PLAYX_SECRET_STRIPE_KEY=pk_live_... dart run playx_core:secure_env --no-file --from-env-prefix PLAYX_SECRET_
```

See the [playx_core README](../README.md#sensitive-values-secure-env) for all options.

## Test

```sh
flutter test
```

The tests load the real `.env` files and the generated secure env.

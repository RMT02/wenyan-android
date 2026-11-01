import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apns_only/flutter_apns_only.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:misskey_dart/misskey_dart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webpush_encryption/webpush_encryption.dart';
import 'package:window_manager/window_manager.dart';

import 'constant/shortcuts.dart';
import 'constant/wenyan.dart';
import 'extension/app_locale_utils_extension.dart';
import 'gen/assets.gen.dart';
import 'hook/on_window_move_hook.dart';
import 'hook/on_window_moved_hook.dart';
import 'hook/on_window_resize_hook.dart';
import 'hook/on_window_resized_hook.dart';
import 'i18n/strings.g.dart';
import 'model/account.dart';
import 'provider/apns_push_connector_provider.dart';
import 'provider/cache_manager_provider.dart';
import 'provider/general_settings_notifier_provider.dart';
import 'provider/notification_settings_repository_provider.dart';
import 'provider/push_notification_notifier_provider.dart';
import 'provider/server_url_notifier_provider.dart';
import 'provider/shared_preferences_provider.dart';
import 'provider/theme_data_provider.dart';
import 'provider/unified_push_endpoint_notifier_provider.dart';
import 'provider/user_ids_notifier_provider.dart';
import 'provider/web_push_key_set_notifier_provider.dart';
import 'provider/wenyan_local_notifications_provider.dart';
import 'provider/wenyan_push_service.dart';
import 'provider/window_position_repository_provider.dart';
import 'provider/window_size_repository_provider.dart';
import 'repository/window_position_repository.dart';
import 'repository/window_size_repository.dart';
import 'router/router.dart';
import 'util/get_retry_delay.dart';
import 'util/wenyan_notification.dart';
import 'view/dialog/error_message_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final asset in Assets.emojis.values) {
      yield LicenseEntryWithLineBreaks([
        'emojis',
      ], await rootBundle.loadString(asset));
    }
    yield LicenseEntryWithLineBreaks([
      'BIZ UDGothic',
    ], await rootBundle.loadString(Assets.fonts.bIZUDGothic.ofl));
    yield LicenseEntryWithLineBreaks([
      'Noto Serif JP',
    ], await rootBundle.loadString(Assets.fonts.notoSerifJP.ofl));
    yield LicenseEntryWithLineBreaks([
      'Pretendard',
    ], await rootBundle.loadString(Assets.fonts.pretendard.license));
    yield LicenseEntryWithLineBreaks([
      'Twemoji Mozilla',
    ], await rootBundle.loadString(Assets.fonts.twemojiMozilla.license));
    for (final asset in Assets.misskey.values) {
      yield LicenseEntryWithLineBreaks([
        'Misskey',
      ], await rootBundle.loadString(asset));
    }
    for (final asset in Assets.twemoji.values) {
      yield LicenseEntryWithLineBreaks([
        'Twemoji',
      ], await rootBundle.loadString(asset));
    }
  });
  late final SharedPreferencesWithCache prefs;
  try {
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  } on FormatException {
    if (defaultTargetPlatform
        case TargetPlatform.linux || TargetPlatform.windows) {
      final directory = await getApplicationSupportDirectory();
      await File(p.join(directory.path, 'shared_preferences.json'))
          .rename(p.join(directory.path, '_shared_preferences.json'));
      prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
    } else {
      rethrow;
    }
  }
  const migrationCompletedKey = 'migrationCompleted';
  if (!prefs.containsKey(migrationCompletedKey)) {
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: await SharedPreferences.getInstance(),
      sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
      migrationCompletedKey: migrationCompletedKey,
    );
    await prefs.reloadCache();
  }
  if (defaultTargetPlatform
      case TargetPlatform.linux ||
          TargetPlatform.macOS ||
          TargetPlatform.windows) {
    await windowManager.ensureInitialized();
    final size = WindowSizeRepository(prefs).getSize();
    final position = WindowPositionRepository(prefs).getPosition();
    final options = WindowOptions(size: size);
    await windowManager.waitUntilReadyToShow(options, () async {
      if (position != null) {
        await windowManager.setPosition(position);
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      retry: getRetryDelay,
      child: TranslationProvider(child: const Aria()),
    ),
  );
}

class const Aria({super.key}) extends HookConsumerWidget {
  Future<void> _init(WidgetRef ref) async {
    final generalSettings = ref.read(generalSettingsNotifierProvider);
    Future(() {
      final locale =
          generalSettings.locale ?? AppLocaleUtils.instance.findDeviceLocale();
      LocaleSettings.instance.setLocale(locale);
    }).ignore();
    if (generalSettings.keepScreenOn) {
      WakelockPlus.enable().ignore();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final flutterLocalNotificationsPlugin = ref.read(
        wenyanLocalNotificationsPluginProvider,
      );
      await flutterLocalNotificationsPlugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _onDidReceiveNotificationResponse(ref, response),
      );

      await UnifiedPush.initialize(
        onNewEndpoint: (endpoint, instance) => ref
            .read(unifiedPushEndpointNotifierProvider(instance).notifier)
            .updateEndpoint(endpoint),
        onRegistrationFailed: (reason, instance) {
          ref
              .read(unifiedPushEndpointNotifierProvider(instance).notifier)
              .remove();
          showErrorMessageDialog(ref.context, error: reason);
        },
        onUnregistered: (instance) => ref
            .read(unifiedPushEndpointNotifierProvider(instance).notifier)
            .remove(),
        onMessage: (message, instance) async {
          Account account = Account.fromString(instance);
          final PushNotification notification;
          if (message.decrypted) {
            final webPushMessage = jsonDecode(
              utf8.decode(message.content),
            ) as Map<String, dynamic>;
            notification = PushNotification.fromJson(webPushMessage);
          } else {
            final keySet = await ref.read(
              webPushKeySetNotifierProvider(account).future,
            );
            if (keySet != null) {
              final decrypted = await WebPush().decrypt(
                keySet,
                message.content,
              );
              final webPushMessage =
                  jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
              notification = PushNotification.fromJson(webPushMessage);
            } else {
              final fcmMessage = jsonDecode(
                utf8.decode(message.content),
              ) as Map<String, dynamic>;
              if (fcmMessage['body'] case final String body) {
                fcmMessage['body'] = jsonDecode(body);
              }
              if (fcmMessage['dateTime'] case final String dateTime) {
                fcmMessage['dateTime'] = int.tryParse(dateTime);
              }
              notification = PushNotification.fromJson(fcmMessage);
              account =
                  ref
                      .read(userIdsNotifierProvider)
                      .entries
                      .firstWhereOrNull((e) => e.value == notification.userId)
                      ?.key ??
                  account;
            }
          }

          await showWenyanNotification(
            plugin: flutterLocalNotificationsPlugin,
            account: account,
            notification: notification,
            generalSettings: generalSettings,
            serverUrl: ref.read(serverUrlNotifierProvider(account.host)),
            resolveImage: (url) async {
              try {
                return await ref
                    .read(cacheManagerProvider)
                    .getSingleFile(url.toString())
                    .timeout(const Duration(seconds: 10));
              } catch (_) {
                return null;
              }
            },
          );
        },
      );

      final appLaunchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (appLaunchDetails?.notificationResponse case final response?) {
        _onDidReceiveNotificationResponse(ref, response);
      }

      // 启动闻言自建推送通道（前台服务 + main 频道长连接）。
      final pushService = ref.read(wenyanPushServiceProvider.notifier);
      pushService.imageResolver = (Uri url) async {
        try {
          return await ref
              .read(cacheManagerProvider)
              .getSingleFile(url.toString())
              .timeout(const Duration(seconds: 10));
        } catch (_) {
          return null;
        }
      };
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      Future<void> onMessageOpenedApp(ApnsRemoteMessage message) async {
        dynamic stringifyKeys(dynamic value) {
          return switch (value) {
            final Map<dynamic, dynamic> value => value.map(
              (key, value) => MapEntry(key.toString(), stringifyKeys(value)),
            ),
            final List<dynamic> value => value.map(stringifyKeys).toList(),
            _ => value,
          };
        }

        if (message.payload['data'] case final Map<dynamic, dynamic> data) {
          if (data['payload'] case final Map<dynamic, dynamic> payload) {
            final notification = PushNotification.fromJson(
              payload.map(
                (key, value) => MapEntry(key.toString(), stringifyKeys(value)),
              ),
            );
            ref
                .read(pushNotificationNotifierProvider.notifier)
                .add(notification);
          }
        }
      }

      final connector = ref.read(apnsPushConnectorProvider);
      connector.configureApns(
        onLaunch: onMessageOpenedApp,
        onResume: onMessageOpenedApp,
      );
      connector.shouldPresent = (_) async => true;
    }
  }

  void _onDidReceiveNotificationResponse(
    WidgetRef ref,
    NotificationResponse response,
  ) {
    if (response.payload case final payload?) {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final notification = PushNotification.fromJson(json);
      ref.read(pushNotificationNotifierProvider.notifier).add(notification);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);    final lightTheme = ref.watch(themeDataProvider(Brightness.light));
    final darkTheme = ref.watch(themeDataProvider(Brightness.dark));
    final themeMode = ref.watch(
      generalSettingsNotifierProvider.select((settings) => settings.themeMode),
    );
    useEffect(() {
      _init(ref);
      return;
    }, []);
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        useOnAppLifecycleStateChange((_, state) async {
          if (state == AppLifecycleState.resumed) {
            final appLaunchDetails = await FlutterLocalNotificationsPlugin()
                .getNotificationAppLaunchDetails();
            if (appLaunchDetails?.notificationResponse case final response?) {
              _onDidReceiveNotificationResponse(ref, response);
            }
          }
        });
      case TargetPlatform.iOS:
        useOnAppLifecycleStateChange((_, state) {
          if (state == AppLifecycleState.resumed) {
            ref.read(notificationSettingsRepositoryProvider).setBadgeCount(0);
          }
        });
      case TargetPlatform.linux:
        final sizeTimer = useMemoized(
          () => RestartableTimer(const Duration(seconds: 1), () async {
            final size = await windowManager.getSize();
            await ref.read(windowSizeRepositoryProvider).setSize(size);
          }),
          [],
        );
        final positionTimer = useMemoized(
          () => RestartableTimer(const Duration(seconds: 1), () async {
            final position = await windowManager.getPosition();
            await ref
                .read(windowPositionRepositoryProvider)
                .setPosition(position);
          }),
          [],
        );
        useOnWindowResize(sizeTimer.reset);
        useOnWindowMove(positionTimer.reset);
      case TargetPlatform.macOS || TargetPlatform.windows:
        useOnWindowResized(() async {
          final size = await windowManager.getSize();
          await ref.read(windowSizeRepositoryProvider).setSize(size);
        });
        useOnWindowMoved(() async {
          final position = await windowManager.getPosition();
          await ref
              .read(windowPositionRepositoryProvider)
              .setPosition(position);
        });
      default:
    }

    return MaterialApp.router(
      routerConfig: router,
      title: wenyanAppName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      scrollBehavior: const _AppScrollBehavior(),
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        darkModeActivator: VoidCallbackIntent(() {
          final themeMode = ref.read(generalSettingsNotifierProvider).themeMode;
          ref.read(generalSettingsNotifierProvider.notifier).setThemeMode(
            switch (themeMode) {
              ThemeMode.system || ThemeMode.light => ThemeMode.dark,
              ThemeMode.dark => ThemeMode.light,
            },
          );
        }),
        focusUpActivator: const DirectionalFocusIntent(TraversalDirection.up),
        focusDownActivator: const DirectionalFocusIntent(
          TraversalDirection.down,
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class const _AppScrollBehavior() extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

import 'dart:ui' as ui;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/max_content_width.dart';
import '../../constant/wenyan_push_types.dart';
import '../../i18n/strings.g.dart';
import '../../provider/general_settings_notifier_provider.dart';
import '../../provider/wenyan_notification_permission_provider.dart';
import '../dialog/wenyan_push_permission_dialog.dart';

/// 打开系统通知设置，返回后刷新权限状态。
Future<void> openWenyanNotificationSettings(WidgetRef ref) async {
  if (defaultTargetPlatform
      case TargetPlatform.android || TargetPlatform.iOS) {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
  if (!ref.context.mounted) return;
  await ref.read(wenyanNotificationPermissionProvider.notifier).refresh();
}

/// 闻言推送设置区块：总开关 + 权限状态 + 逐类型开关。
///
/// 「设置 → 通知」（`/settings/notifications`）与账户通知页共用这一份 UI，
/// 保证两处看到的状态与可改的开关完全一致。
class const WenyanPushSettingsSection({
  super.key,
  final bool showHeader = true,
}) extends ConsumerWidget {
  Future<void> _enable(WidgetRef ref) async {
    final granted = await ref
        .read(wenyanNotificationPermissionProvider.notifier)
        .request();
    if (!ref.context.mounted) return;
    // 权限没拿到也照样把总开关打开：用户之后在系统设置里授权，
    // 下一轮同步就会开始推送，不需要再回来手动打开一次。
    await ref
        .read(generalSettingsNotifierProvider.notifier)
        .setWenyanPushEnabled(true);
    if (!granted && ref.context.mounted) {
      await showWenyanPushPermissionDialog(ref: ref, context: ref.context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsNotifierProvider);
    final permissionDenied =
        ref.watch(wenyanNotificationPermissionProvider).value == false;
    final theme = Theme.of(context);
    final enabled = settings.wenyanPushEnabled;
    const types = WenyanPushType.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          const SizedBox(height: 24.0),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              width: maxContentWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                t.aria.wenyanPush,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              width: maxContentWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                t.aria.wenyanPushDescription,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
        ],
        if (permissionDenied)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              width: maxContentWidth,
              child: Material(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.0),
                clipBehavior: ui.Clip.hardEdge,
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_off_outlined,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    t.aria.wenyanPushPermissionDenied,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    t.aria.wenyanPushPermissionDeniedDescription,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: t.aria.wenyanPushRecheckPermission,
                    icon: const Icon(Icons.refresh),
                    color: theme.colorScheme.onErrorContainer,
                    onPressed: () => ref
                        .read(wenyanNotificationPermissionProvider.notifier)
                        .refresh(),
                  ),
                  onTap: () => openWenyanNotificationSettings(ref),
                ),
              ),
            ),
          ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            width: maxContentWidth,
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              clipBehavior: ui.Clip.hardEdge,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(t.aria.wenyanPushEnabled),
                    value: enabled,
                    onChanged: (value) => value
                        ? _enable(ref)
                        : ref
                              .read(generalSettingsNotifierProvider.notifier)
                              .setWenyanPushEnabled(false),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: maxContentWidth,
                        child: Divider(height: 0.0),
                      ),
                    ),
                  ),
                  if (defaultTargetPlatform
                      case TargetPlatform.android || TargetPlatform.iOS)
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: Text(t.aria.openNotificationSettings),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () => openWenyanNotificationSettings(ref),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(t.aria.wenyanPushRecheckPermission),
                      onTap: () => ref
                          .read(wenyanNotificationPermissionProvider.notifier)
                          .refresh(),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (enabled) ...[
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              width: maxContentWidth,
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
              child: Text(
                t.aria.wenyanPushTypes,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              width: maxContentWidth,
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                clipBehavior: ui.Clip.hardEdge,
                child: Column(
                  children: [
                    for (final (index, type) in types.indexed) ...[
                      if (index > 0)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: maxContentWidth,
                              child: Divider(height: 0.0),
                            ),
                          ),
                        ),
                      SwitchListTile(
                        title: Text(type.label),
                        value: !settings.wenyanPushDisabledTypes.contains(
                          type.key,
                        ),
                        onChanged: (value) => ref
                            .read(generalSettingsNotifierProvider.notifier)
                            .setWenyanPushTypeEnabled(type.key, value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

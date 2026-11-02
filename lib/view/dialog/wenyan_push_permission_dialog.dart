import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../i18n/strings.g.dart';
import '../../provider/wenyan_notification_permission_provider.dart';

/// 通知权限未获取时的提示对话框。
///
/// 用户拒绝、系统拦截或调用失败都会走到这里：文案统一为「通知权限未获取，
/// 通知不可用」，并提供一键跳到系统通知设置的入口。
Future<void> showWenyanPushPermissionDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final action = await showDialog<_WenyanPushPermissionAction>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.notifications_off_outlined, size: 36.0),
      title: Text(t.aria.wenyanPushPermissionDenied),
      content: Text(t.aria.wenyanPushPermissionDeniedDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.misskey.close),
        ),
        if (defaultTargetPlatform
            case TargetPlatform.android || TargetPlatform.iOS)
          ElevatedButton(
            autofocus: true,
            onPressed: () => Navigator.of(
              context,
            ).pop(_WenyanPushPermissionAction.openSettings),
            child: Text(t.aria.openNotificationSettings),
          ),
      ],
    ),
  );
  if (action != _WenyanPushPermissionAction.openSettings) return;
  await AppSettings.openAppSettings(type: AppSettingsType.notification);
  if (!context.mounted) return;
  await ref.read(wenyanNotificationPermissionProvider.notifier).refresh();
}

enum _WenyanPushPermissionAction { openSettings }

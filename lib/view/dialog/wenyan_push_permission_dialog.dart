import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/wenyan_root_navigator_key.dart';
import '../../i18n/strings.g.dart';
import '../../provider/wenyan_notification_permission_provider.dart';

/// 通知权限未获取时的提示对话框。
///
/// 用户拒绝、系统拦截或调用失败都会走到这里：文案统一为「通知权限未获取，
/// 通知不可用」，并提供一键跳到系统通知设置的入口。
///
/// [context] 可以省略：首次运行时的申请流程发生在 `Aria` 组件里，那个 context
/// 位于 `MaterialApp` 之上、没有 Navigator 祖先，只能走根 Navigator 的 key。
Future<void> showWenyanPushPermissionDialog({
  required WidgetRef ref,
  BuildContext? context,
}) async {
  final ctx = context ?? await _waitForNavigatorContext();
  if (ctx == null || !ctx.mounted) return;
  final action = await showDialog<_WenyanPushPermissionAction>(
    context: ctx,
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
  await ref.read(wenyanNotificationPermissionProvider.notifier).refresh();
}

/// 等根 Navigator 就绪。`MaterialApp.router` 的 Navigator 在首帧之后才可用，
/// 启动阶段的提示可能比它早几毫秒。
Future<BuildContext?> _waitForNavigatorContext() async {
  for (var i = 0; i < 40; i++) {
    final context = wenyanRootNavigatorKey.currentContext;
    if (context != null) return context;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return null;
}

enum _WenyanPushPermissionAction { openSettings }

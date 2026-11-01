import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wenyan_local_notifications_provider.g.dart';

/// 全局唯一的本地通知插件实例。
///
/// UnifiedPush 通路与闻言自建推送通道共用同一个实例：初始化只做一次
/// （`main.dart` 里），两边都用它发通知，避免出现两套通知渠道配置。
@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin wenyanLocalNotificationsPlugin(Ref ref) {
  final plugin = FlutterLocalNotificationsPlugin();
  ref.onDispose(plugin.cancelAll);
  return plugin;
}

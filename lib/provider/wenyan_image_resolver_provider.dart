import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wenyan_image_resolver_provider.g.dart';

/// 通知大图的解析结果类型。
typedef WenyanImageResolver = Future<File?> Function(Uri url);

/// 通知大图解析器的持有者。
///
/// 通知里的头像 / 自定义表情要走 Isar 图片缓存拿到本地文件，才能作为
/// `largeIcon` 显示；但 `cacheManagerProvider` 是 autoDispose 的，不能在
/// keepAlive 的推送服务里直接读（lint `only_use_keep_alive_inside_keep_alive`）。
/// 因此改由 UI 层在启动时把解析函数写进这里，推送服务读同一个实例。
///
/// 用「可变持有者」而不是 provider state，是为了避免状态变化触发 notifier
/// 重建 —— 重建会丢掉正在用的 WebSocket 长连接。
class WenyanImageResolverHolder {
  WenyanImageResolver? resolve;
}

@Riverpod(keepAlive: true)
WenyanImageResolverHolder wenyanImageResolver(Ref ref) =>
    WenyanImageResolverHolder();

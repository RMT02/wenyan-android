import 'package:material_ui/material_ui.dart';

/// 应用根 Navigator 的 key。
///
/// `MaterialApp.router` 内部的 Navigator 是 Flutter 自己创建的，`Aria` 组件的
/// context 位于 `MaterialApp` 之上，没有 Navigator 祖先。启动阶段（首帧之后的
/// 通知权限提示等）需要弹对话框时，只能通过这个 key 拿到真正带 Navigator 的
/// context，否则 `showDialog` 会抛 `Navigator.of()` 的空值断言。
final wenyanRootNavigatorKey = GlobalKey<NavigatorState>();

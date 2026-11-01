import 'package:misskey_dart/misskey_dart.dart';

import '../i18n/strings.g.dart';

/// 闻言推送支持的通知类型。
///
/// 这里的 `key` 与 Misskey 服务端 `notification.type` 的取值一致
/// （见 `MiNotification`），私信单独使用 `newChatMessage`，
/// 无法识别的类型或分组类型统一落到 [other]。
enum WenyanPushType {
  note,
  follow,
  mention,
  reply,
  renote,
  quote,
  reaction,
  pollEnded,
  scheduledNotePosted,
  scheduledNotePostFailed,
  receiveFollowRequest,
  followRequestAccepted,
  roleAssigned,
  chatRoomInvitationReceived,
  achievementEarned,
  exportCompleted,
  login,
  createToken,
  app,
  test,
  newChatMessage,
  other;

  /// 用作持久化键，同时也是服务端 `notification.type` 的字符串。
  String get key => name;

  String get label => switch (this) {
    WenyanPushType.note => t.misskey.notification_.types_.note,
    WenyanPushType.follow => t.misskey.notification_.types_.follow,
    WenyanPushType.mention => t.misskey.notification_.types_.mention,
    WenyanPushType.reply => t.misskey.notification_.types_.reply,
    WenyanPushType.renote => t.misskey.notification_.types_.renote,
    WenyanPushType.quote => t.misskey.notification_.types_.quote,
    WenyanPushType.reaction => t.misskey.notification_.types_.reaction,
    WenyanPushType.pollEnded => t.misskey.notification_.types_.pollEnded,
    WenyanPushType.scheduledNotePosted =>
      t.misskey.notification_.types_.scheduledNotePosted,
    WenyanPushType.scheduledNotePostFailed =>
      t.misskey.notification_.types_.scheduledNotePostFailed,
    WenyanPushType.receiveFollowRequest =>
      t.misskey.notification_.types_.receiveFollowRequest,
    WenyanPushType.followRequestAccepted =>
      t.misskey.notification_.types_.followRequestAccepted,
    WenyanPushType.roleAssigned => t.misskey.notification_.types_.roleAssigned,
    WenyanPushType.chatRoomInvitationReceived =>
      t.misskey.notification_.types_.chatRoomInvitationReceived,
    WenyanPushType.achievementEarned =>
      t.misskey.notification_.types_.achievementEarned,
    WenyanPushType.exportCompleted =>
      t.misskey.notification_.types_.exportCompleted,
    WenyanPushType.login => t.misskey.notification_.types_.login,
    WenyanPushType.createToken => t.misskey.notification_.types_.createToken,
    WenyanPushType.app => t.misskey.notification_.types_.app,
    WenyanPushType.test => t.misskey.notification_.types_.test,
    WenyanPushType.newChatMessage => t.misskey.directMessage,
    WenyanPushType.other => t.misskey.other,
  };

  /// 服务端 `notification.type` 里能直接对应到开关的取值；
  /// 其余（`edited` / `reaction:grouped` / `pollVote` 等）归入 [other]。
  static const _known = {
    'note',
    'follow',
    'mention',
    'reply',
    'renote',
    'quote',
    'reaction',
    'pollEnded',
    'scheduledNotePosted',
    'scheduledNotePostFailed',
    'receiveFollowRequest',
    'followRequestAccepted',
    'roleAssigned',
    'chatRoomInvitationReceived',
    'achievementEarned',
    'exportCompleted',
    'login',
    'createToken',
    'app',
    'test',
  };

  static WenyanPushType fromKey(String? key) {
    if (key == null) return other;
    if (!_known.contains(key)) return other;
    return values.firstWhere((e) => e.name == key, orElse: () => other);
  }

  /// 判断一条待推送的通知属于哪个开关。
  static WenyanPushType? of(PushNotification notification) {
    return switch (notification) {
      NewChatMessagePushNotification() => newChatMessage,
      NotificationPushNotification(body: PushNotificationBody(:final type)) =>
        fromKey(type?.name),
      // 「全部已读」之类的推送不产生系统通知。
      ReadAllNotificationsPushNotification() => null,
    };
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:misskey_dart/misskey_dart.dart';

import '../constant/colors.dart';
import '../extension/app_locale_utils_extension.dart';
import '../extension/user_extension.dart';
import '../i18n/strings.g.dart';
import '../model/account.dart';
import '../model/general_settings.dart';
import '../model/id.dart';
import 'twemoji.dart';

/// [PushNotification] 到 Android 本地通知的唯一渲染实现。
///
/// UnifiedPush 通路（`main.dart`）与闻言自建通道
/// （`provider/wenyan_push_notifier_provider.dart`）共用这一份代码，
/// 保证两条通路产出的通知标题、正文、通道名、分组、图标完全一致。
Future<void> showWenyanNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required Account account,
  required PushNotification notification,
  required GeneralSettings generalSettings,
  required Uri serverUrl,
  required Future<File?> Function(Uri url) resolveImage,
}) async {
  final currentLocale = LocaleSettings.currentLocale;
  if (generalSettings.locale case final locale?) {
    if (locale != currentLocale) {
      await LocaleSettings.setLocale(locale);
    }
  } else if (AppLocaleUtils.instance.findDeviceLocale()
      case final locale when locale != currentLocale) {
    await LocaleSettings.setLocale(locale);
  }

  final acct = account.toString();

  final channel = switch (notification) {
    NotificationPushNotification(:final body) => switch (body.type) {
      NotificationType.note => AndroidNotificationChannel(
        '$account/note',
        t.misskey.notification_.types_.note,
        groupId: acct,
      ),
      NotificationType.follow => AndroidNotificationChannel(
        '$account/follow',
        t.misskey.notification_.types_.follow,
        groupId: acct,
      ),
      NotificationType.mention => AndroidNotificationChannel(
        '$account/mention',
        t.misskey.notification_.types_.mention,
        groupId: acct,
      ),
      NotificationType.reply => AndroidNotificationChannel(
        '$account/reply',
        t.misskey.notification_.types_.reply,
        groupId: acct,
      ),
      NotificationType.renote => AndroidNotificationChannel(
        '$account/renote',
        t.misskey.notification_.types_.renote,
        groupId: acct,
      ),
      NotificationType.quote => AndroidNotificationChannel(
        '$account/quote',
        t.misskey.notification_.types_.quote,
        groupId: acct,
      ),
      NotificationType.reaction => AndroidNotificationChannel(
        '$account/reaction',
        t.misskey.notification_.types_.reaction,
        groupId: acct,
      ),
      NotificationType.pollEnded => AndroidNotificationChannel(
        '$account/pollEnded',
        t.misskey.notification_.types_.pollEnded,
        groupId: acct,
      ),
      NotificationType.scheduledNotePosted =>
        AndroidNotificationChannel(
          '$account/scheduledNotePosted',
          t.misskey.notification_.types_.scheduledNotePosted,
          groupId: acct,
        ),
      NotificationType.scheduledNotePostFailed ||
      NotificationType.scheduleNote ||
      NotificationType.scheduledNoteError => AndroidNotificationChannel(
        '$account/scheduledNotePostFailed',
        t.misskey.notification_.types_.scheduledNotePostFailed,
        groupId: acct,
      ),
      NotificationType.receiveFollowRequest =>
        AndroidNotificationChannel(
          '$account/receiveFollowRequest',
          t.misskey.notification_.types_.receiveFollowRequest,
          groupId: acct,
        ),
      NotificationType.followRequestAccepted =>
        AndroidNotificationChannel(
          '$account/followRequestAccepted',
          t.misskey.notification_.types_.followRequestAccepted,
          groupId: acct,
        ),
      NotificationType.roleAssigned => AndroidNotificationChannel(
        '$account/roleAssigned',
        t.misskey.notification_.types_.roleAssigned,
        groupId: acct,
      ),
      NotificationType.chatRoomInvitationReceived =>
        AndroidNotificationChannel(
          '$account/chatRoomInvitationReceived',
          t.misskey.notification_.types_.chatRoomInvitationReceived,
          groupId: acct,
        ),
      NotificationType.achievementEarned => AndroidNotificationChannel(
        '$account/achievementEarned',
        t.misskey.notification_.types_.achievementEarned,
        groupId: acct,
      ),
      NotificationType.exportCompleted => AndroidNotificationChannel(
        '$account/exportCompleted',
        t.misskey.notification_.types_.exportCompleted,
        groupId: acct,
      ),
      NotificationType.login => AndroidNotificationChannel(
        '$account/login',
        t.misskey.notification_.types_.login,
        groupId: acct,
      ),
      NotificationType.createToken => AndroidNotificationChannel(
        '$account/createToken',
        t.misskey.notification_.types_.createToken,
        groupId: acct,
      ),
      NotificationType.app => AndroidNotificationChannel(
        '$account/app',
        t.misskey.notification_.types_.app,
        groupId: acct,
      ),
      NotificationType.test => AndroidNotificationChannel(
        '$account/test',
        t.misskey.notification_.types_.test,
        groupId: acct,
      ),
      NotificationType.edited ||
      NotificationType.noteScheduled ||
      NotificationType.reactionGrouped ||
      NotificationType.renoteGrouped ||
      NotificationType.noteGrouped ||
      NotificationType.pollVote ||
      NotificationType.groupInvited ||
      null => AndroidNotificationChannel(
        '$account/other',
        t.misskey.other,
        groupId: acct,
      ),
    },
    ReadAllNotificationsPushNotification() =>
      AndroidNotificationChannel(
        '$account/other',
        t.misskey.other,
        groupId: acct,
      ),
    NewChatMessagePushNotification() => AndroidNotificationChannel(
      '$account/newChatMessage',
      t.misskey.directMessage,
      groupId: acct,
    ),
  };
  final androidPlugin = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  // 渠道是按账号分组的（`groupId: acct`），Android 要求分组先存在，
  // 否则 createNotificationChannel 会抛 IllegalArgumentException:
  // NotificationChannelGroup doesn't exist，而调用点为了不让推送拖垮
  // App 会把这个异常吞掉 —— 表现为「一条通知都不弹」。UnifiedPush 通路
  // 之所以没事，是因为订阅时顺带建过分组；自建通道必须自己建。
  await androidPlugin?.createNotificationChannelGroup(
    AndroidNotificationChannelGroup(acct, acct),
  );
  await androidPlugin?.createNotificationChannel(channel);

  final title = switch (notification) {
    NotificationPushNotification(:final body) => switch (body.type) {
      NotificationType.follow =>
        t.misskey.notification_.youWereFollowed,
      NotificationType.mention => t.misskey.notification_.youGotMention(
        name: body.user?.nameOrUsername ?? '',
      ),
      NotificationType.reply => t.misskey.notification_.youGotReply(
        name: body.user?.nameOrUsername ?? '',
      ),
      NotificationType.renote => t.misskey.notification_.youRenoted(
        name: body.user?.nameOrUsername ?? '',
      ),
      NotificationType.quote => t.misskey.notification_.youGotQuote(
        name: body.user?.nameOrUsername ?? '',
      ),
      NotificationType.note => t.misskey.notification_.newNote,
      NotificationType.reaction => [
        body.reaction?.split('@')[0].replaceAll(':', ''),
        body.user?.nameOrUsername,
      ].nonNulls.join(' '),
      NotificationType.receiveFollowRequest =>
        t.misskey.notification_.youReceivedFollowRequest,
      NotificationType.followRequestAccepted =>
        t.misskey.notification_.yourFollowRequestAccepted,
      NotificationType.achievementEarned =>
        t.misskey.notification_.achievementEarned,
      NotificationType.login => t.misskey.notification_.login,
      NotificationType.exportCompleted =>
        t.misskey.notification_.exportOfXCompleted(
          x: switch (body.exportedEntity) {
            UserExportableEntities.antenna => t.misskey.antennas,
            UserExportableEntities.blocking => t.misskey.blockedUsers,
            UserExportableEntities.clip => t.misskey.clips,
            UserExportableEntities.customEmoji =>
              t.misskey.customEmojis,
            UserExportableEntities.favorite => t.misskey.favorites,
            UserExportableEntities.following => t.misskey.following,
            UserExportableEntities.muting => t.misskey.mutedUsers,
            UserExportableEntities.note => t.misskey.notes,
            UserExportableEntities.userList => t.misskey.lists,
            null => '',
          },
        ),
      NotificationType.pollEnded => t.misskey.notification_.pollEnded,
      NotificationType.roleAssigned =>
        t.misskey.notification_.roleAssigned,
      NotificationType.chatRoomInvitationReceived =>
        t.misskey.notification_.chatRoomInvitationReceived,
      NotificationType.createToken =>
        t.misskey.notification_.createToken,
      NotificationType.scheduledNotePosted =>
        t.misskey.notification_.scheduledNotePosted,
      NotificationType.scheduledNotePostFailed ||
      NotificationType.scheduleNote ||
      NotificationType.scheduledNoteError =>
        t.misskey.notification_.scheduledNotePostFailed,
      NotificationType.noteScheduled => t.aria.noteScheduled,
      NotificationType.app => body.header ?? body.body,
      NotificationType.test => t.misskey.notification_.testNotification,
      NotificationType.edited ||
      NotificationType.reactionGrouped ||
      NotificationType.renoteGrouped ||
      NotificationType.noteGrouped ||
      NotificationType.pollVote ||
      NotificationType.groupInvited ||
      null => null,
    },
    ReadAllNotificationsPushNotification() => null,
    NewChatMessagePushNotification(:final body) =>
      body.toRoom != null
          ? '${body.toRoom?.name}: ${body.fromUser?.nameOrUsername}'
          : body.fromUser?.nameOrUsername,
  };
  final body = switch (notification) {
    NotificationPushNotification(:final body) => switch (body.type) {
      NotificationType.follow ||
      NotificationType.receiveFollowRequest ||
      NotificationType.followRequestAccepted =>
        body.user?.nameOrUsername,
      NotificationType.mention ||
      NotificationType.reply ||
      NotificationType.renote ||
      NotificationType.quote ||
      NotificationType.note ||
      NotificationType.reaction ||
      NotificationType.pollEnded => body.note?.text,
      NotificationType.achievementEarned => switch (body.achievement) {
        'notes1' => t.misskey.achievements_.types_.notes1_.title,
        'notes10' => t.misskey.achievements_.types_.notes10_.title,
        'notes100' => t.misskey.achievements_.types_.notes100_.title,
        'notes500' => t.misskey.achievements_.types_.notes500_.title,
        'notes1000' => t.misskey.achievements_.types_.notes1000_.title,
        'notes5000' => t.misskey.achievements_.types_.notes5000_.title,
        'notes10000' =>
          t.misskey.achievements_.types_.notes10000_.title,
        'notes20000' =>
          t.misskey.achievements_.types_.notes20000_.title,
        'notes30000' =>
          t.misskey.achievements_.types_.notes30000_.title,
        'notes40000' =>
          t.misskey.achievements_.types_.notes40000_.title,
        'notes50000' =>
          t.misskey.achievements_.types_.notes50000_.title,
        'notes60000' =>
          t.misskey.achievements_.types_.notes60000_.title,
        'notes70000' =>
          t.misskey.achievements_.types_.notes70000_.title,
        'notes80000' =>
          t.misskey.achievements_.types_.notes80000_.title,
        'notes90000' =>
          t.misskey.achievements_.types_.notes90000_.title,
        'notes100000' =>
          t.misskey.achievements_.types_.notes100000_.title,
        'login3' => t.misskey.achievements_.types_.login3_.title,
        'login7' => t.misskey.achievements_.types_.login7_.title,
        'login15' => t.misskey.achievements_.types_.login15_.title,
        'login30' => t.misskey.achievements_.types_.login30_.title,
        'login60' => t.misskey.achievements_.types_.login60_.title,
        'login100' => t.misskey.achievements_.types_.login100_.title,
        'login200' => t.misskey.achievements_.types_.login200_.title,
        'login300' => t.misskey.achievements_.types_.login300_.title,
        'login400' => t.misskey.achievements_.types_.login400_.title,
        'login500' => t.misskey.achievements_.types_.login500_.title,
        'login600' => t.misskey.achievements_.types_.login600_.title,
        'login700' => t.misskey.achievements_.types_.login700_.title,
        'login800' => t.misskey.achievements_.types_.login800_.title,
        'login900' => t.misskey.achievements_.types_.login900_.title,
        'login1000' => t.misskey.achievements_.types_.login1000_.title,
        'noteClipped1' =>
          t.misskey.achievements_.types_.noteClipped1_.title,
        'noteFavorited1' =>
          t.misskey.achievements_.types_.noteFavorited1_.title,
        'myNoteFavorited1' =>
          t.misskey.achievements_.types_.myNoteFavorited1_.title,
        'profileFilled' =>
          t.misskey.achievements_.types_.profileFilled_.title,
        'markedAsCat' =>
          t.misskey.achievements_.types_.markedAsCat_.title,
        'following1' =>
          t.misskey.achievements_.types_.following1_.title,
        'following10' =>
          t.misskey.achievements_.types_.following10_.title,
        'following50' =>
          t.misskey.achievements_.types_.following50_.title,
        'following100' =>
          t.misskey.achievements_.types_.following100_.title,
        'following300' =>
          t.misskey.achievements_.types_.following300_.title,
        'followers1' =>
          t.misskey.achievements_.types_.followers1_.title,
        'followers10' =>
          t.misskey.achievements_.types_.followers10_.title,
        'followers50' =>
          t.misskey.achievements_.types_.followers50_.title,
        'followers100' =>
          t.misskey.achievements_.types_.followers100_.title,
        'followers300' =>
          t.misskey.achievements_.types_.followers300_.title,
        'followers500' =>
          t.misskey.achievements_.types_.followers500_.title,
        'followers1000' =>
          t.misskey.achievements_.types_.followers1000_.title,
        'collectAchievements30' =>
          t.misskey.achievements_.types_.collectAchievements30_.title,
        'viewAchievements3min' =>
          t.misskey.achievements_.types_.viewAchievements3min_.title,
        'iLoveMisskey' =>
          t.misskey.achievements_.types_.iLoveMisskey_.title,
        'foundTreasure' =>
          t.misskey.achievements_.types_.foundTreasure_.title,
        'client30min' =>
          t.misskey.achievements_.types_.client30min_.title,
        'client60min' =>
          t.misskey.achievements_.types_.client60min_.title,
        'noteDeletedWithin1min' =>
          t.misskey.achievements_.types_.noteDeletedWithin1min_.title,
        'postedAtLateNight' =>
          t.misskey.achievements_.types_.postedAtLateNight_.title,
        'postedAt0min0sec' =>
          t.misskey.achievements_.types_.postedAt0min0sec_.title,
        'selfQuote' => t.misskey.achievements_.types_.selfQuote_.title,
        'htl20npm' => t.misskey.achievements_.types_.htl20npm_.title,
        'viewInstanceChart' =>
          t.misskey.achievements_.types_.viewInstanceChart_.title,
        'outputHelloWorldOnScratchpad' =>
          t
              .misskey
              .achievements_
              .types_
              .outputHelloWorldOnScratchpad_
              .title,
        'open3windows' =>
          t.misskey.achievements_.types_.open3windows_.title,
        'driveFolderCircularReference' =>
          t
              .misskey
              .achievements_
              .types_
              .driveFolderCircularReference_
              .title,
        'reactWithoutRead' =>
          t.misskey.achievements_.types_.reactWithoutRead_.title,
        'clickedClickHere' =>
          t.misskey.achievements_.types_.clickedClickHere_.title,
        'justPlainLucky' =>
          t.misskey.achievements_.types_.justPlainLucky_.title,
        'setNameToSyuilo' =>
          t.misskey.achievements_.types_.setNameToSyuilo_.title,
        'passedSinceAccountCreated1' =>
          t
              .misskey
              .achievements_
              .types_
              .passedSinceAccountCreated1_
              .title,
        'passedSinceAccountCreated2' =>
          t
              .misskey
              .achievements_
              .types_
              .passedSinceAccountCreated2_
              .title,
        'passedSinceAccountCreated3' =>
          t
              .misskey
              .achievements_
              .types_
              .passedSinceAccountCreated3_
              .title,
        'loggedInOnBirthday' =>
          t.misskey.achievements_.types_.loggedInOnBirthday_.title,
        'loggedInOnNewYearsDay' =>
          t.misskey.achievements_.types_.loggedInOnNewYearsDay_.title,
        'cookieClicked' =>
          t.misskey.achievements_.types_.cookieClicked_.title,
        'brainDiver' =>
          t.misskey.achievements_.types_.brainDiver_.title,
        'smashTestNotificationButton' =>
          t
              .misskey
              .achievements_
              .types_
              .smashTestNotificationButton_
              .title,
        'tutorialCompleted' =>
          t.misskey.achievements_.types_.tutorialCompleted_.title,
        'bubbleGameExplodingHead' =>
          t.misskey.achievements_.types_.bubbleGameExplodingHead_.title,
        'bubbleGameDoubleExplodingHead' =>
          t
              .misskey
              .achievements_
              .types_
              .bubbleGameDoubleExplodingHead_
              .title,
        _ => null,
      },
      NotificationType.roleAssigned => body.role?.name,
      NotificationType.chatRoomInvitationReceived =>
        body.invitation?.room?.name,
      NotificationType.createToken =>
        t.misskey.notification_.createTokenDescription(
          text: t.misskey.manageAccessTokens,
        ),
      NotificationType.scheduleNote => body.errorType,
      NotificationType.noteScheduled => body.draft?.data.text,
      NotificationType.scheduledNotePosted => body.note?.text,
      NotificationType.scheduledNoteError => body.draft?.reason,
      NotificationType.app => body.header != null ? body.body : null,
      NotificationType.test =>
        t.misskey.notification_.notificationWillBeDisplayedLikeThis,
      NotificationType.scheduledNotePostFailed ||
      NotificationType.edited ||
      NotificationType.exportCompleted ||
      NotificationType.login ||
      NotificationType.reactionGrouped ||
      NotificationType.renoteGrouped ||
      NotificationType.noteGrouped ||
      NotificationType.pollVote ||
      NotificationType.groupInvited ||
      null => null,
    },
    ReadAllNotificationsPushNotification() => null,
    NewChatMessagePushNotification(:final body) => body.text,
  };

  final url = switch (notification) {
    NotificationPushNotification(
      body: PushNotificationBody(
        type: NotificationType.reaction,
        :final note,
        :final reaction?,
      ),
    )
        when generalSettings.showEmojiInReactionNotification =>
      reaction.startsWith(':')
          ? switch ((
              serverUrl,
              reaction.substring(1, reaction.length - 1),
            )) {
              (final serverUrl, final emoji) => switch ({
                ...?note?.emojis,
                ...?note?.reactionEmojis,
              }[emoji]) {
                final url? => serverUrl.replace(
                  pathSegments: ['proxy', 'image.webp'],
                  queryParameters: {'url': url, 'emoji': '1'},
                ),
                _ => serverUrl.replace(
                  pathSegments: ['emoji', '$emoji.webp'],
                ),
              },
            }
          : getTwemojiUrl(reaction),
    NotificationPushNotification(:final body) =>
      body.user?.avatarUrl ?? body.icon,
    NewChatMessagePushNotification(:final body) =>
      body.fromUser?.avatarUrl,
    _ => null,
  };
  String? filePath;
  if (url != null && generalSettings.showImageInNotification) {
    try {
      final file = await resolveImage(url);
      filePath = file?.path;
    } catch (_) {}
  }

  await plugin.show(
    id: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        styleInformation: BigTextStyleInformation(body ?? ''),
        groupKey: acct,
        groupAlertBehavior: GroupAlertBehavior.children,
        color: ariaColor,
        largeIcon: filePath != null
            ? FilePathAndroidBitmap(filePath)
            : null,
        when: notification.dateTime?.millisecondsSinceEpoch,
        subText: acct,
        tag: switch (notification) {
          NotificationPushNotification(
            body: PushNotificationBody(:final id),
          ) ||
          NewChatMessagePushNotification(
            body: ChatMessage(:final id),
          ) => id,
          _ => null,
        },
      ),
    ),
    payload: jsonEncode(notification),
  );

  final userId = notification.userId;
  final summaryId = userId != null
      ? Id.tryParse(userId)?.date.millisecondsSinceEpoch
      : null;
  await plugin.show(
    id: (summaryId ?? 0) & 0x7fffffff,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        groupKey: acct,
        setAsGroupSummary: true,
        groupAlertBehavior: GroupAlertBehavior.children,
        color: ariaColor,
        subText: acct,
      ),
    ),
    payload: jsonEncode(
      ReadAllNotificationsPushNotification(userId: notification.userId),
    ),
  );
}

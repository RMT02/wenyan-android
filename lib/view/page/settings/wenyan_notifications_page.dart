import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constant/max_content_width.dart';
import '../../../i18n/strings.g.dart';
import '../../../provider/accounts_notifier_provider.dart';
import '../../widget/general_settings_scaffold.dart';
import '../../widget/wenyan_push_settings_section.dart';

/// 设置 → 通知。
///
/// 闻言的推送是全局的（一条长连接覆盖本机所有账户），所以开关放在设置首页
/// 一级入口，不再藏在「设置 → 账户 → 通知」里。各账户的通知页仍从下面这里
/// 进入，用来看该账户的通知历史偏好。
class const WenyanNotificationsPage({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsNotifierProvider);
    final theme = Theme.of(context);

    return GeneralSettingsScaffold(
      appBar: AppBar(title: Text(t.misskey.notifications)),
      selectedDestination: GeneralSettingsDestination.notifications,
      body: ListView(
        children: [
          const WenyanPushSettingsSection(),
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 24.0),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                width: maxContentWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  t.misskey.accounts,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                width: maxContentWidth,
                child: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      for (final (index, account) in accounts.indexed) ...[
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
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(account.toString()),
                          subtitle: Text(t.misskey.notifications),
                          trailing: const Icon(Icons.navigate_next),
                          onTap: () => context.push(
                            '/settings/accounts/$account/notifications',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

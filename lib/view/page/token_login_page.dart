import 'dart:async';
import 'dart:ui';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/max_content_width.dart';
import '../../constant/shortcuts.dart';
import '../../constant/wenyan.dart';
import '../../i18n/strings.g.dart';
import '../../model/tab_settings.dart';
import '../../provider/accounts_notifier_provider.dart';
import '../../provider/timeline_tabs_notifier_provider.dart';
import '../../util/future_with_dialog.dart';
import '../../util/punycode.dart';
import '../../util/show_toast.dart';

class const TokenLoginPage({super.key, final String? query})
    extends HookConsumerWidget {
  Future<void> _login(WidgetRef ref, String query, String token) async {
    final trimmed = query.trim();
    final match = RegExp(
      '^(https?://)?([^/]*)',
      caseSensitive: false,
    ).firstMatch(trimmed);
    final scheme = match?[1]?.toLowerCase() ?? 'https://';
    final host = toAscii(match?[2] ?? trimmed).toLowerCase();
    final serverUrl = Uri.parse('$scheme$host');
    if (!ref.context.mounted) return;
    final result = await ref
        .read(accountsNotifierProvider.notifier)
        .loginWithToken(serverUrl, token);
    // 与账号密码登录保持一致：首次登录自动准备主时间线。
    if (ref.read(timelineTabsNotifierProvider).isEmpty) {
      await ref
          .read(timelineTabsNotifierProvider.notifier)
          .add(TabSettings.localTimeline(result.account));
    }
    showToast(
      context: ref.context.mounted ? ref.context : null,
      message: result.added ? t.aria.accountAdded : t.aria.accessTokenUpdated,
    );
    if (!ref.context.mounted) return;
    ref.context.go('/timelines');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 闻言版把服务器固定为内置实例，本页不再提供服务器选择。
    final tokenController = useTextEditingController();
    final token = useState('');
    final tokenFocusNode = useFocusNode();
    useEffect(() {
      tokenController.addListener(() => token.value = tokenController.text);
      return;
    }, []);

    return Scaffold(
      body: Column(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: AppBar(
                title: Text(t.aria.loginWithAccessToken),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: maxContentWidth,
                child: Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 56,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/wenyan.png',
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const ColoredBox(
                                        color: wenyanColor,
                                        child: Center(
                                          child: Text(
                                            '闻',
                                            style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // 闻言版服务器固定，这里只做展示，不提供切换。
                        Row(
                          children: [
                            const Icon(Icons.dns, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                wenyanServerUrl.host,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Shortcuts(
                          shortcuts: {
                            ...disablingTextShortcuts,
                            submitActivator: VoidCallbackIntent(
                              () => tokenController.text.isNotEmpty
                                  ? futureWithDialog(
                                      context,
                                      _login(
                                        ref,
                                        wenyanServerUrl.host,
                                        tokenController.text,
                                      ),
                                    )
                                  : null,
                            ),
                          },
                          child: TextField(
                            controller: tokenController,
                            focusNode: tokenFocusNode,
                            decoration: InputDecoration(
                              labelText: t.misskey.accessToken,
                              prefixIcon: const Icon(Icons.key),
                              suffixIcon: IconButton(
                                onPressed: () => tokenController.clear(),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            onTapOutside: (_) => primaryFocus?.unfocus(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed:
                              token.value.isNotEmpty
                              ? () => futureWithDialog(
                                  context,
                                  _login(
                                    ref,
                                    wenyanServerUrl.host,
                                    tokenController.text,
                                  ),
                                )
                              : null,
                          icon: const Icon(Icons.key),
                          label: Text(t.misskey.login),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

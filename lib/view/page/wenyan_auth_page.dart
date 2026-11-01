import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/max_content_width.dart';
import '../../constant/wenyan.dart';
import '../../model/tab_settings.dart';
import '../../provider/accounts_notifier_provider.dart';
import '../../provider/dio_provider.dart';
import '../../provider/timeline_tabs_notifier_provider.dart';
import '../../repository/wenyan_auth_repository.dart';
import '../../util/show_toast.dart';
import '../dialog/message_dialog.dart';

const _logoAsset = 'assets/icons/wenyan.png';

/// 闻言专用登录 / 注册页面。
///
/// 服务器地址内置为闻言实例，用户无需（也无法）输入服务器地址；
/// 登录与注册均直接调用闻言后端接口，全程不离开应用。
class const WenyanAuthPage({super.key, final String? query})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = useState(_AuthMode.login);
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final obscure = useState(true);
    final busy = useState(false);
    final pendingEmail = useState(false);

    final isRegister = mode.value == _AuthMode.register;

    Future<void> submit() async {
      if (busy.value) return;
      final username = usernameController.text.trim();
      final password = passwordController.text;
      if (username.isEmpty || password.isEmpty) {
        await showMessageDialog(context, '请填写用户名和密码。');
        return;
      }
      FocusScope.of(context).unfocus();
      busy.value = true;
      final repository = WenyanAuthRepository(ref.read(dioProvider));
      try {
        final WenyanSession session;
        if (isRegister) {
          if (pendingEmail.value) {
            final code = codeController.text.trim();
            if (code.isEmpty) {
              await showMessageDialog(context, '请填写邮件里的验证码。');
              return;
            }
            session = await repository.signupPending(code: code);
          } else {
            session = await repository.signup(
              username: username,
              password: password,
              emailAddress: emailController.text.trim(),
            );
          }
        } else {
          session = await repository.signin(
            username: username,
            password: password,
          );
        }
        final result = await ref
            .read(accountsNotifierProvider.notifier)
            .login(
              serverUrl: wenyanServerUrl,
              username: session.username.isEmpty ? username : session.username,
              token: session.token,
              userId: session.userId,
            );
        if (!context.mounted) return;
        // 首次登录时自动准备一个主时间线，做到打开即用。
        // 必须用 login() 返回的账号：它的 host 是服务端解析出的规范值、
        // 用户名也非空；自行拼 Account 会拼出 host 不一致的「假账号」，
        // 导致时间线取不到令牌、报「请先登录」。
        if (ref.read(timelineTabsNotifierProvider).isEmpty) {
          await ref
              .read(timelineTabsNotifierProvider.notifier)
              .add(TabSettings.homeTimeline(result.account));
        }
        if (!context.mounted) return;
        showToast(
          context: context,
          message: result.added ? '已登录闻言' : '已更新闻言账户',
        );
        context.go('/timelines');
      } on WenyanEmailVerificationRequired {
        if (!context.mounted) return;
        pendingEmail.value = true;
        await showMessageDialog(context, '验证邮件已发送到你的邮箱，请填写邮件中的验证码完成注册。');
      } on WenyanAuthException catch (e) {
        if (!context.mounted) return;
        await showMessageDialog(context, e.message);
      } catch (e) {
        if (!context.mounted) return;
        await showMessageDialog(context, '发生未知错误：$e');
      } finally {
        busy.value = false;
      }
    }

    void switchMode(_AuthMode next) {
      if (busy.value) return;
      mode.value = next;
      pendingEmail.value = false;
      codeController.clear();
      HapticFeedback.selectionClick();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: maxContentWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 96,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          _logoAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const ColoredBox(
                                color: wenyanColor,
                                child: Center(
                                  child: Text(
                                    '闻',
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      wenyanAppName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                            color: wenyanColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wenyanServerUrl.host,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SegmentedButton<_AuthMode>(
                              segments: const [
                                ButtonSegment(
                                  value: _AuthMode.login,
                                  label: Text('登录'),
                                ),
                                ButtonSegment(
                                  value: _AuthMode.register,
                                  label: Text('注册'),
                                ),
                              ],
                              selected: {mode.value},
                              showSelectedIcon: false,
                              onSelectionChanged: (selection) =>
                                  switchMode(selection.first),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: usernameController,
                              autofocus: true,
                              enabled: !busy.value,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: '用户名',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordController,
                              enabled: !busy.value,
                              obscureText: obscure.value,
                              textInputAction: isRegister
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onSubmitted: isRegister ? null : (_) => submit(),
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      obscure.value = !obscure.value,
                                  icon: Icon(
                                    obscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            if (isRegister) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: emailController,
                                enabled: !busy.value && !pendingEmail.value,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: '邮箱',
                                  prefixIcon: Icon(Icons.mail_outline),
                                  helperText: '用于接收验证邮件与找回密码',
                                ),
                              ),
                              if (pendingEmail.value) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: codeController,
                                  enabled: !busy.value,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => submit(),
                                  decoration: const InputDecoration(
                                    labelText: '验证码',
                                    prefixIcon: Icon(
                                      Icons.mark_email_read_outlined,
                                    ),
                                    helperText: '请查看验证邮件中的链接或验证码',
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: busy.value ? null : submit,
                                icon: busy.value
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isRegister
                                            ? Icons.person_add_alt_1
                                            : Icons.login,
                                      ),
                                label: Text(
                                  isRegister
                                      ? (pendingEmail.value ? '完成注册' : '注册并登录')
                                      : '登录',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: busy.value
                          ? null
                          : () => context.push('/login/token'),
                      child: const Text('使用访问令牌登录'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _AuthMode { login, register }

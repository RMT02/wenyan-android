import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'accounts_notifier_provider.dart';
import 'timeline_tabs_notifier_provider.dart';
import 'tokens_notifier_provider.dart';

part 'boot_state_provider.g.dart';

@riverpod
class BootState extends _$BootState {
  @override
  FutureOr<bool?> build() {
    return null;
  }

  Future<void> boot() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final accounts = ref.read(accountsNotifierProvider);
      await Future.wait(
        accounts.map(
          (account) => ref.read(tokensNotifierProvider.notifier).load(account),
        ),
      );
      // 老版本可能留下绑定空用户名的标签页，启动时顺手修掉。
      await ref
          .read(timelineTabsNotifierProvider.notifier)
          .repairAccounts(accounts);
      return true;
    });
  }
}

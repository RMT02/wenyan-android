import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/wenyan.dart';
import '../../i18n/strings.g.dart';
import '../../model/account.dart';
import '../../provider/accounts_notifier_provider.dart';

class const AccountSelectDialog({super.key, final Account? initialAccount})
    extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsNotifierProvider);
    final account = useState(initialAccount);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(t.misskey.selectAccount),
      scrollable: true,
      content: RadioGroup<(Account?,)>(
        groupValue: switch (account.value) {
          Account(isGuest: true) => (null,),
          Account(isGuest: false) => (account.value,),
          null => null,
        },
        onChanged: (value) {
          if (value != null) {
            if (value.$1 != null) {
              account.value = value.$1;
            } else {
              account.value = Account(host: wenyanServerUrl.host);
            }
          }
        },
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(t.misskey.addAccount),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => context.push('/login'),
            ),
            ...accounts.map(
              (account) => RadioListTile<(Account?,)>(
                title: Text(account.toString()),
                value: (account,),
              ),
            ),
            RadioListTile<(Account?,)>(
              title: Text(t.aria.guest),
              value: (null,),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(account.value),
          child: Text(t.misskey.ok),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
          ),
          onPressed: () => context.pop(),
          child: Text(t.misskey.cancel),
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';

/// 服务器地址输入框。
///
/// 闻言面向单一实例，服务器地址在应用内固定，这里只用于「按主机检索远程
/// 用户」这类需要手填域名的场景，因此不提供实例发现与自动补全。
class const ServerHostField({
  super.key,
  required final TextEditingController controller,
  required final FocusNode focusNode,
  final String? labelText,
  final String? hintText,
  final bool autofocus = false,
  final ValueChanged<String>? onSubmitted,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.dns),
        labelText: labelText,
        hintText: hintText,
      ),
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onTapOutside: (_) => focusNode.unfocus(),
    );
  }
}

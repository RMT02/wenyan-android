import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../constant/max_content_width.dart';
import '../../constant/wenyan.dart';
import '../../i18n/strings.g.dart';

/// 闻言的许可信息页。
///
/// Flutter 自带的 `LicensePage` 会把每个依赖包的**包名**原样列出来，其中包含
/// 上游项目的包标识。这里改为自行渲染 `LicenseRegistry` 的内容：许可正文一字
/// 不改，只把展示用的包名换成闻言的名称。
class const WenyanLicensePage({
  super.key,
  required final String? version,
  required final Widget? icon,
  final String? legalese,
}) extends StatefulWidget {
  @override
  State<WenyanLicensePage> createState() => _WenyanLicensePageState();
}

class _WenyanLicensePageState extends State<WenyanLicensePage> {
  late final Future<List<_LicensePackage>> packages = _load();

  static Future<List<_LicensePackage>> _load() async {
    final entries = await LicenseRegistry.licenses.toList();
    final grouped = <String, List<LicenseParagraph>>{};
    for (final entry in entries) {
      final name = _sanitizePackageName(entry.packages.join(', '));
      (grouped[name] ??= []).addAll(entry.paragraphs);
    }
    final packages = [
      for (final entry in grouped.entries)
        _LicensePackage(entry.key, entry.value),
    ];
    packages.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return packages;
  }

  /// 把依赖包名换成本应用的称呼，避免在界面上出现上游项目的标识。
  static String _sanitizePackageName(String name) {
    final lower = name.toLowerCase();
    if (lower == 'aria' || lower.startsWith('aria_')) return wenyanAppName;
    if (lower.contains('misskey')) return '$wenyanAppName API';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.misskey.license)),
      body: FutureBuilder<List<_LicensePackage>>(
        future: packages,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final packages = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Text(
                        wenyanAppName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      ?widget.icon,
                      if (widget.version case final version?
                          when version.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            version,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (widget.legalese case final legalese?
                          when legalese.isNotEmpty)
                        Text(
                          legalese,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: packages.length + 1,
                itemBuilder: (context, index) {
                  if (index == packages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Divider(),
                    );
                  }
                  final package = packages[index];
                  return ListTile(
                    title: Text(
                      package.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(package.name),
                        content: SizedBox(
                          width: maxContentWidth,
                          child: SingleChildScrollView(
                            child: Text(package.text),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(t.misskey.close),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LicensePackage {
  const new(this.name, this.paragraphs);

  final String name;
  final List<LicenseParagraph> paragraphs;

  String get text => paragraphs.map((p) => p.text).join('\n\n');
}

import 'dart:ui';

/// 闻言（Wenyan）实例的固定信息。
///
/// 服务器地址以 XOR 混淆后内置，客户端不向用户暴露服务器选择界面。
const _wenyanServerUrlKey = <int>[
  0x57, 0x65, 0x6e, 0x79, 0x61, 0x6e, 0x32, 0x30, 0x32, 0x30, //
];

const _wenyanServerUrlData = <int>[
  0x3f, 0x11, 0x1a, 0x09, 0x12, 0x54, 0x1d, 0x1f, 0x5f, 0x59, 0x24, 0x16, //
  0x05, 0x1c, 0x18, 0x40, 0x02, 0x02, 0x02, 0x02, 0x67, 0x5c, 0x40, 0x01, //
  0x18, 0x14,
];

/// 解密后的服务器地址。
String get wenyanServerUrlString => String.fromCharCodes(
  List<int>.generate(
    _wenyanServerUrlData.length,
    (i) =>
        _wenyanServerUrlData[i] ^
        _wenyanServerUrlKey[i % _wenyanServerUrlKey.length],
  ),
);

/// 闻言服务器地址。
final Uri wenyanServerUrl = Uri.parse(wenyanServerUrlString);

/// 应用名称。
const wenyanAppName = '闻言';

/// 闻言品牌色。
const wenyanColor = Color(0xff8ec621);

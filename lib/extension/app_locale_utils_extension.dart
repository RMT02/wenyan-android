import '../i18n/strings.g.dart';

extension AppLocaleUtilsExtension on AppLocaleUtils {
  AppLocale findDeviceLocale() {
    // 聞言版：首次启动一律使用简体中文界面，不跟随系统语言，
    // 避免在英文系统上出现整屏英文。用户可在
    // 设置 → 通用 → 语言 中自行切换为其它语言。
    return AppLocale.zhCn;
  }
}

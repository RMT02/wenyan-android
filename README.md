# 闻言（Wenyan）

闻言是面向单一实例 `misskey.020209.xyz` 的 Android 社交客户端，使用 Flutter 构建。
应用内已内置服务器地址，打开即用，无需自行配置实例。

## 功能

- 登录与注册都在应用内完成，无需跳转浏览器
- 时间线：本地 / 首页 / 社交 / 全局 / 列表 / 天线 / 频道 / 收藏
- 发帖、回复、引用、转贴、回应、投票
- 私聊、通知中心、云盘、表情选择器（含自定义表情）
- MFM 与 HTML 富文本渲染、GIF 播放、主题与配色自定义
- 推送通知：全部站内通知类型 + 私聊，支持逐类型开关
- 多账户与游客模式

## 下载

构建产物发布在本仓库的 Release 页面：

| 架构 | 适配设备 |
| --- | --- |
| `arm64-v8a` | 绝大多数现代手机 |
| `armeabi-v7a` | 老旧 32 位设备 |
| `x86_64` | 模拟器 |

## 构建

APK 由 GitHub Actions 构建，工作流见 `.github/workflows/wenyan-build.yml`。
构建需要以下仓库 secrets：

| Secret | 用途 |
| --- | --- |
| `UPLOAD_KEYSTORE` | 签名密钥库（base64） |
| `KEY_ALIAS` | 密钥别名 |
| `KEY_PASSWORD` | 密钥口令 |
| `STORE_PASSWORD` | 密钥库口令 |

本地调试可执行：

```bash
flutter pub get
dart run slang
flutter run
```

## 许可

本项目遵循 GNU Affero General Public License v3.0，详见 [LICENSE](LICENSE)。

界面文本与音效素材源自上游开源项目，版权归各自作者所有；
相关许可条文见 `assets/wenyan/` 目录，也可在应用内「设置 → 关于闻言 → 许可信息」查看。

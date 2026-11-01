/// 闻言：Unicode 表情分组名的中文显示名。
///
/// 分组键来自 `categorized_unicode_emojis.g.dart`（由
/// emojis/packages/emoji-data/src/emojilist.json 生成），
/// 原样是英文标识符，在界面上显示时统一替换为中文名。
const unicodeEmojiCategoryLabels = <String, String>{
  'face': '表情',
  'people': '人物',
  'animals_and_nature': '动物与自然',
  'food_and_drink': '食物与饮品',
  'activity': '活动',
  'travel_and_places': '旅行与地点',
  'objects': '物品',
  'symbols': '符号',
  'flags': '旗帜',
};

/// 把分组键翻译成显示名；未知分组原样返回。
String localizeUnicodeEmojiCategory(String category) =>
    unicodeEmojiCategoryLabels[category] ?? category;

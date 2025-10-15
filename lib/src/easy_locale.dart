///
///字符串翻译扩展
///
extension EasyLocale on String {
  ///翻译语言数据
  static Map<String, Map<String, String>> _languageData = {};

  ///翻译语言环境
  static String _languageCode = 'zh';

  ///获取语言环境
  static String get languageCode => _languageCode;

  ///改变语言环境
  static void setLanguageCode(String code) => _languageCode = code;

  ///设置语言数据
  static void setLanguageData(Map<String, Map<String, String>> data) => _languageData = data;

  ///设置语言字段
  static void setLanguageItem(String key, Map<String, String> item) {
    var valMap = _languageData[key];
    if (valMap == null) {
      valMap = {};
      _languageData[key] = valMap;
    }
    valMap.addAll(item);
  }

  ///翻译本字符串对应当前语言的值
  String get trs => _languageData[this]?[_languageCode] ?? this;

  ///翻译本字符串对应指定语言的值
  String trsCode(String code) => _languageData[this]?[code] ?? this;

  ///翻译本字符串对应当前语言的值，并替换参数
  String trsParams(Map<String, String> params) {
    var template = trs;
    params.forEach((key, value) {
      template = template.replaceAll('@$key', value);
    });
    return template;
  }
}

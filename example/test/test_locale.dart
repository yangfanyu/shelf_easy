import 'package:shelf_easy/shelf_easy.dart';

void main() {
  EasyLocale.setLanguageData(
    {
      '你好': {'en': 'Hello'},
      '世界': {'en': 'World'},
      '我是 @name': {'en': 'I am @name'},
      '翻译器': {'en': 'Translator'},
    },
  );

  print('${'你好'.trs} ${'世界'.trs}, ${'我是 @name'.trsFree(args: {'name': '翻译器'.trs})}'); //你好 世界, 我是 翻译器

  EasyLocale.setLanguageCode('en');

  print('${'你好'.trs} ${'世界'.trs}, ${'我是 @name'.trsFree(args: {'name': '翻译器'.trs})}'); //Hello World, I am Translator

  final goodUseful = '这个翻译器很好用。';

  print(goodUseful.trs); //这个翻译器很好用。

  EasyLocale.setLanguageItem(goodUseful, {'en': 'This translator is good useful.', 'ru': 'Этот переводчик хорошо полезен.'});

  print(goodUseful.trs); //This translator is good useful.

  print(goodUseful.trsFree(code: 'ru')); //Этот переводчик хорошо полезен.

  print('未定义翻译内容的字符串'.trs); //未定义翻译内容的字符串
}

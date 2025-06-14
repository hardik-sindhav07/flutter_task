import 'package:translator/translator.dart';

Future<String> translateToHindi(String text) async {
  final translator = GoogleTranslator();
  var translation = await translator.translate(text, from: 'en', to: 'hi');
  return translation.text;
}

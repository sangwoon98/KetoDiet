import 'secret.dart';

String decoding(String string) {
  String result = '';

  for (var i = 0; i < string.length; i++) {
    late bool isUpper;

    if (string[i] == '대') {
      isUpper = true;
      i++;
    } else {
      isUpper = false;
    }

    String char = string[i];

    if (dictForKoreanToHex.containsKey(char)) {
      String add =
          String.fromCharCode(int.parse(dictForKoreanToHex[char]!, radix: 16));
      add = isUpper ? add.toUpperCase() : add;
      result = result + add;
    } else {
      return ('$char not defined in dict.');
    }
  }

  return (result);
}

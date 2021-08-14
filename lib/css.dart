// https://drafts.csswg.org/css-style-attr/#style-attribute

import 'dart:collection';

final S = RegExp('[ \t\r\n\f]+');

LinkedHashMap<String, String> parseStyle(String styleAttribute) {
  var match = RegExp('(?:' + S.pattern + ')*').matchAsPrefix(styleAttribute);
  String declarationList;
  if (match == null) {
    declarationList = styleAttribute;
  } else {
    declarationList = styleAttribute.substring(match.end);
  }
  var style = LinkedHashMap<String, String>();
  var declarations = declarationList.split(RegExp(';(?:' + S.pattern + ')*'));
  for (var declaration in declarations) {
    var tmp = declaration
        .split(RegExp('(?:' + S.pattern + ')*:(?:' + S.pattern + ')*'));
    if (tmp.length == 2) {
      var property = tmp.first;
      var value = tmp.last;
      style[property] = value;
    }
  }
  return style;
}

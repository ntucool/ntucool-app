import 'package:flutter/material.dart';

/// Parse [source] as a, possibly signed, integer literal.
///
/// If [source] is [int], it is returned.
///
/// If [source] is [String], the result of [int.tryParse] called with [source]
/// and [int] is returned.
///
/// In other cases, `null` is returned.
int? tryParseInt(Object? source, {int? radix}) {
  if (source is int) {
    return source;
  } else if (source is String) {
    return int.tryParse(source, radix: radix);
  }
  return null;
}

/// Returns a new lazy [Iterable] with all elements that are [T].
///
/// If [source] is not [Iterable], `null` is returned.
Iterable<T>? whereIterable<T>(Object? source) {
  Iterable<T>? result;
  if (source is Iterable) {
    result = source.where((element) => element is T).cast<T>();
  }
  return result;
}

T? castOrNull<T>(Object? source) {
  if (source is T) {
    return source;
  }
  return null;
}

String? tryFormat(
  String format(DateTime date),
  Object? formattedString, {
  bool isUtc = true,
}) {
  if (formattedString is String) {
    var date = DateTime.tryParse(formattedString);
    if (date != null) {
      if (isUtc) {
        date = date.toUtc();
      } else {
        date = date.toLocal();
      }
      return format(date);
    }
  }
  return null;
}

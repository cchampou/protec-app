import 'package:flutter/material.dart';

PreferredSizeWidget appBar({String? title}) {

  // if title is not null, add it to the default title
  final String fullTitle = title ?? 'ProtecApp';

  return AppBar(
    title: Text(fullTitle),
  );
}

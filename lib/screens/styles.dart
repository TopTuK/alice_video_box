import 'package:flutter/material.dart';

final cHintTextStyle = const TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans'
);

final cLabelStyle = const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans'
);

final cBoxDecorationStyle = new BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final cTitleStyle = new TextStyle(
  color: Colors.white,
  fontFamily: 'CM Sans Serif',
  fontSize: 26.0,
  height: 1.5,
);

final cSubtitleStyle = const TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  height: 1.2,
);
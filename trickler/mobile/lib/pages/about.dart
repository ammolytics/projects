/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../widgets/header.dart';

class AboutPage extends StatelessWidget {
  AboutPage({ Key key }) : super(key: key);

  final String title = 'About Trickler';
  final String about = """
This is the Open Trickler Mobile App. This app allows you to connect to your Open Trickler Controller, and make accurate measurements with ease.

Open Trickler is an open source project by Ammolytics.
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Header(
          key: Key('Header'),
          title: this.title,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(this.about),
        ),
      ),
    );
  }
}

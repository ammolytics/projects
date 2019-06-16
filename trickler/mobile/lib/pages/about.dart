/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/header.dart';

/// AboutPage is a StatelessWidget that provides the user a description
/// of the project, as well as links to the repo and license.

class AboutPage extends StatelessWidget {
  AboutPage({ Key key }) : super(key: key);

  final String title = 'About Open Trickler';
  final String about = """
This is the Open Trickler Mobile App. This app allows you to connect to your Open Trickler Controller, and make accurate measurements with ease.

Open Trickler is an open source project by Ammolytics.
  """;

  /// _launchUrl attempts to open the given url in the users default
  /// browser. If it is unable to open the url it will throw an error.

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// _getLink returns a Flat button that displays the
  /// given text, and opens the given url onPressed.

  Widget _getLink(String text, String url) => FlatButton(
    onPressed: () => _launchUrl(url),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.blue,
      ),
    ),
  );

  /// _getHeading returns a SizedBox that contains the logo, and title of the page.

  Widget _getHeading() => SizedBox(
    height: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('assets/logo.png'),
        Text(
          'Open Trickler',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

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
        child: Column(
          children: <Widget>[
            _getHeading(),
            Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Text(
                '\u00a9 2019 Ammolytics',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 115, 115, 115),
                ),
              ),
            ),
            Text(
              this.about,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _getLink('GITHUB', 'https://github.com/ammolytics/projects'),
                _getLink('LICENSE', 'https://github.com/ammolytics/projects/blob/master/LICENSE'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

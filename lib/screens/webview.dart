import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:protec_app/components/app_bar.dart';

class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {

    final WebViewController controller = WebViewController()
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: appBar(title: title),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

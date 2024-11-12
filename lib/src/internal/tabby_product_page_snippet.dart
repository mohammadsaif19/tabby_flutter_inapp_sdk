// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyProductPageSnippet extends StatefulWidget {
  const TabbyProductPageSnippet({
    required this.price,
    required this.currency,
    required this.lang,
    required this.merchantCode,
    required this.apiKey,
    this.borderColor = const Color(0xFFD6DED6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF292929),
    Key? key,
  }) : super(key: key);
  final String price;
  final Currency currency;
  final Lang lang;
  final String merchantCode;
  final String apiKey;

  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  @override
  State<TabbyProductPageSnippet> createState() =>
      _TabbyProductPageSnippetState();
}

class _TabbyProductPageSnippetState extends State<TabbyProductPageSnippet> {
  late InAppWebViewController controller;

  @override
  void initState() {
    TabbySDK().logEvent(
      AnalyticsEvent.snipperCardRendered,
      EventProperties(
        currency: widget.currency,
        lang: widget.lang,
        installmentsCount: 4,
      ),
    );
    super.initState();
  }

  Future<void> setupDataAndProceedWithLoading() async {
    final price =
        double.tryParse(widget.price)?.toStringAsFixed(2) ?? widget.price;
    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <script
      type="text/javascript"
      src="https://checkout.tabby.ai/tabby-promo.js"
    ></script>
  </head>
  <body>
    <div id="tabbyPromo"></div>
    <script>
      new TabbyPromo({
        selector: "#tabbyPromo",
        currency: "${widget.currency.displayName}",
        price: "$price",
        installmentsCount: "4",
        locale: "en",
      });
    </script>
  </body>
</html>
''';
    await controller.loadData(data: html, mimeType: 'text/html');
    // await controller.loadUrl(
    //   urlRequest: URLRequest(
    //     url: WebUri.uri(
    //       Uri.parse('https://tabby.ai'),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 720, maxHeight: 80),
      child: InAppWebView(
        initialSettings: _settings,
        // onConsoleMessage: (controller, consoleMessage) => print(consoleMessage),
        onWebViewCreated: (controller) {
          this.controller = controller;
          setupDataAndProceedWithLoading();
        },
      ),
    );
  }
}

InAppWebViewSettings _settings = InAppWebViewSettings(
  mediaPlaybackRequiresUserGesture: false,
  verticalScrollBarEnabled: false,
  cacheMode: CacheMode.LOAD_NO_CACHE,
  sharedCookiesEnabled: true,
  clearCache: true,
  allowUniversalAccessFromFileURLs: true,
  domStorageEnabled: true,
  databaseEnabled: true,
  allowFileAccess: true,
  allowContentAccess: true,
  allowFileAccessFromFileURLs: true,
  thirdPartyCookiesEnabled: true,
  networkAvailable: true,
);

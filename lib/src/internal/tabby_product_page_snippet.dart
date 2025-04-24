import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabbyProductPageSnippet extends StatefulWidget {
  const TabbyProductPageSnippet({
    required this.price,
    required this.currency,
    required this.lang,
    required this.merchantCode,
    required this.apiKey,
    Key? key,
  }) : super(key: key);
  final double price;
  final Currency currency;
  final Lang lang;
  final String merchantCode;
  final String apiKey;

  @override
  State<TabbyProductPageSnippet> createState() =>
      _TabbyProductPageSnippetState();
}

class _TabbyProductPageSnippetState extends State<TabbyProductPageSnippet> {
  double height = 98;
  final WebViewController webViewController = createBaseWebViewController(
    (message) {
      // TODO: listen to events `onChangeDimensions` and `onLearnMoreClicked`
    },
  );

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

    final address = 'https://widgets.tabby.dev/tabby-promo.html'
        '?price=${widget.price}'
        '&currency=${widget.currency.displayName}'
        '&publicKey=${widget.apiKey}'
        '&merchantCode=${widget.merchantCode}'
        '&lang=${widget.lang.displayName}'
        '&platform=flutter';

    webViewController.loadRequest(Uri.parse(address));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: height,
      ),
      child: WebViewWidget(
        controller: webViewController,
      ),
    );
  }
}

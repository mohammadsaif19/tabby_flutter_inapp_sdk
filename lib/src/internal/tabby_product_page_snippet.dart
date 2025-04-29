import 'dart:convert';

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
  late final WebViewController webViewController;

  void messageHandler(JavaScriptMessage message) {
    final json = jsonDecode(message.message) as Map<String, dynamic>;
    final type = JSEventTypeMapper.fromDto(json['type']);
    if (type == null) {
      return;
    }
    if (type == JSEventType.onChangeDimensions) {
      final event = DimentionsChangeEvent.fromJson(json);
      final dimentions = event.data;
      print(dimentions);
      setState(() {});
    }
    if (type == JSEventType.onLearnMoreClicked) {
      final event = LearnMoreClickedEvent.fromJson(json);
      final params = event.data;
      // final browser = ChromeSafariBrowser();
      // browser.open(
      //   url: WebUri.uri(Uri.parse(params)),
      //   settings: ChromeSafariBrowserSettings(
      //     shareState: CustomTabsShareState.SHARE_STATE_OFF,
      //     presentationStyle: ModalPresentationStyle.POPOVER,
      //   ),
      // );
      print(params);
      final controller = WebViewController();
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.addJavaScriptChannel(
        'tabbyMobileSDK',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("Message from JS: ${message.message}");
        },
      );
      controller.loadRequest(Uri.parse('https://flutter.dev'));
      // controller.runJavaScript
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.94,
            child: WebViewWidget(
              controller: controller,
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    final address = 'https://widgets.tabby.ai/tabby-promo.html'
        '?price=${widget.price}'
        '&currency=${widget.currency.displayName}'
        '&publicKey=${widget.apiKey}'
        '&merchantCode=${widget.merchantCode}'
        '&lang=${widget.lang.displayName}'
        '&platform=flutter';
    webViewController = createBaseWebViewController(messageHandler);
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

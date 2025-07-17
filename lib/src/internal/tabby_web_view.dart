import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

const tabbyColor = Color.fromRGBO(62, 237, 191, 1);

typedef TabbyCheckoutCompletion = void Function(WebViewResult resultCode);

@Deprecated('Use TabbyWebView instead')
class TabbyWebViewDeprecated extends StatefulWidget {
  const TabbyWebViewDeprecated({
    required this.webUrl,
    required this.onResult,
    Key? key,
  }) : super(key: key);

  final String webUrl;
  final TabbyCheckoutCompletion onResult;

  @override
  State<TabbyWebViewDeprecated> createState() => _TabbyWebViewDeprecatedState();

  static void showWebView({
    required BuildContext context,
    required String webUrl,
    required TabbyCheckoutCompletion onResult,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.94,
          child: TabbyWebViewDeprecated(
            webUrl: webUrl,
            onResult: onResult,
          ),
        );
      },
    );
  }
}

extension TabbyPermissionResourceType1 on WebViewPermissionResourceType {
  static Permission? toAndroidPermission(WebViewPermissionResourceType value) {
    if (value == WebViewPermissionResourceType.camera) {
      return Permission.camera;
    } else if (value == WebViewPermissionResourceType.microphone) {
      return Permission.microphone;
    } else {
      return null;
    }
  }
}

extension TabbyPermissionResourceType2 on PermissionResourceType {
  static Permission? toAndroidPermission(PermissionResourceType value) {
    if (value == PermissionResourceType.CAMERA) {
      return Permission.camera;
    } else if (value == PermissionResourceType.MICROPHONE) {
      return Permission.microphone;
    } else {
      return null;
    }
  }
}

// ignore: deprecated_member_use_from_same_package
class _TabbyWebViewDeprecatedState extends State<TabbyWebViewDeprecated> {
  final GlobalKey webViewKey = GlobalKey();
  double _progress = 0;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = createBaseWebViewController((message) {
      javaScriptHandlerWVF(message.message, widget.onResult);
    });
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
      ),
    );
    webViewController.loadRequest(Uri.parse(widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1) ...[
          LinearProgressIndicator(
            value: _progress,
            color: tabbyColor,
            backgroundColor: Colors.black,
          )
        ],
        Expanded(
          key: webViewKey,
          child: WebViewWidget(
            controller: webViewController,
          ),
        ),
      ],
    );
  }
}

final settings = InAppWebViewSettings(
  mediaPlaybackRequiresUserGesture: false,
  applePayAPIEnabled: true,
  useOnNavigationResponse: true,
);

class TabbyWebView extends StatefulWidget {
  const TabbyWebView({
    required this.webUrl,
    required this.onResult,
    Key? key,
  }) : super(key: key);
  final String webUrl;
  final TabbyCheckoutCompletion onResult;
  @override
  State<TabbyWebView> createState() => _TabbyWebViewState();
  static void showWebView({
    required BuildContext context,
    required String webUrl,
    required TabbyCheckoutCompletion onResult,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.94,
          child: TabbyWebView(
            webUrl: webUrl,
            onResult: onResult,
          ),
        );
      },
    );
  }
}

class _TabbyWebViewState extends State<TabbyWebView> {
  final GlobalKey webViewKey = GlobalKey();
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1) ...[
          LinearProgressIndicator(
            value: _progress,
            color: tabbyColor,
            backgroundColor: Colors.black,
          )
        ],
        Expanded(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: WebUri.uri(Uri.parse(widget.webUrl))),
            initialSettings: settings,
            onPermissionRequest: (controller, permissionRequest) async {
              final resources = permissionRequest.resources;
              final permissions = Platform.isAndroid
                  ? resources
                      .map((r) {
                        final permission =
                            TabbyPermissionResourceType2.toAndroidPermission(r);
                        return permission;
                      })
                      .whereType<Permission>()
                      .toList()
                  : [Permission.camera, Permission.microphone];
              if (permissions.isEmpty) {
                return PermissionResponse(
                  action: PermissionResponseAction.GRANT,
                  resources: resources,
                );
              }
              final statuses = await permissions.request();
              final isGranted = statuses.values.every((s) => s.isGranted);
              return PermissionResponse(
                action: isGranted
                    ? PermissionResponseAction.GRANT
                    : PermissionResponseAction.DENY,
                resources: resources,
              );
            },
            onProgressChanged: (
              InAppWebViewController controller,
              int progress,
            ) {
              setState(() {
                _progress = progress / 100;
              });
            },
            onWebViewCreated: (controller) async {
              controller.addJavaScriptHandler(
                handlerName: TabbySDK.jsBridgeName,
                callback: (message) => javaScriptHandlerFIWV(
                  message,
                  widget.onResult,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

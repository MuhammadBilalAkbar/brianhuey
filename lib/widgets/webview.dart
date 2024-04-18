import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  const WebView(this.url, {super.key});

  final String url;

  @override
  State<WebView> createState() => WebViewState();
}

WebViewController webViewController = WebViewController();

class WebViewState extends State<WebView> {
  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..runJavaScriptReturningResult(
              "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()")
          .then((value) => debugPrint('Page finished loading Javascript'))
          .catchError((onError) => debugPrint('$onError'))
      // ..setNavigationDelegate(
      //   NavigationDelegate(
      //     onPageStarted: (url) => debugPrint('Page started loading: $url'),
      //     onPageFinished: (url) => debugPrint('Page finished loading: $url'),
      //     onUrlChange: (change) => debugPrint('url changed to ${change.url}'),
      //     onProgress: (progress) =>
      //         debugPrint('WebView is loading (progress : $progress%)'),
      //     onWebResourceError: (error) =>
      //         debugPrint('Page resource error code: ${error.errorCode}'),
      //     onNavigationRequest: (request) {
      //       if (request.url.startsWith('https://www.facebook.com')) {
      //         debugPrint('blocking navigation to ${request.url}');
      //         return NavigationDecision.prevent;
      //       }
      //       return NavigationDecision.navigate;
      //     },
      //   ),
      // )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    webViewController.loadRequest(Uri.parse('about:blank'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvoked: (_) => onWillPop,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top),
            child: SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          body: WebViewWidget(controller: webViewController),
        ),
      );
}

Future<bool> onWillPop() async {
  if (await webViewController.canGoBack()) {
    webViewController.goBack();
    return false;
  } else {
    return true;
  }
}

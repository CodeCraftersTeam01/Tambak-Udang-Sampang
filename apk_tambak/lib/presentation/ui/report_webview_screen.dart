import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/security/secure_storage.dart';

class ReportWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const ReportWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<ReportWebViewScreen> createState() => _ReportWebViewScreenState();
}

class _ReportWebViewScreenState extends State<ReportWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final token = await SecureStorage().getToken();

    final webController = WebViewController();

    webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B1326))
      ..setUserAgent('TambakAppWebView')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (token != null) {
              try {
                await webController.runJavaScript(
                  "try { localStorage.setItem('token', '$token'); } catch (e) { console.error('Token injection failed: ', e); }"
                );
              } catch (e) {
                debugPrint("Error injecting token onPageFinished: $e");
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame != true) return;
            if (!mounted) return;
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

    if (!mounted) return;
    setState(() {
      _controller = webController;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    if (_hasError) {
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat halaman Web. Periksa Port dan Server Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                    _controller = null;
                  });
                  _initWebView();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    } else if (_isLoading || _controller == null) {
      bodyWidget = const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    } else {
      bodyWidget = WebViewWidget(controller: _controller!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: bodyWidget,
    );
  }
}

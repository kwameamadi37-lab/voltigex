import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Page interne : document légal avec AppBar fixe et WebView.
///
/// Le chargement et le [WebViewController] sont gérés par [_LegalWebViewBody]
/// (Stateful) pour permettre à cette page d’être un [StatelessWidget].
class LegalWebViewPage extends StatelessWidget {
  const LegalWebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: DefaultColors.blackColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: DefaultColors.blackColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
      ),
      body: _LegalWebViewBody(url: url),
    );
  }
}

class _LegalWebViewBody extends StatefulWidget {
  const _LegalWebViewBody({required this.url});

  final String url;

  @override
  State<_LegalWebViewBody> createState() => _LegalWebViewBodyState();
}

class _LegalWebViewBodyState extends State<_LegalWebViewBody> {
  WebViewController? _controller;
  var _loading = true;
  var _errorSnackShown = false;

  void _showLoadErrorOnce() {
    if (_errorSnackShown || !mounted) return;
    _errorSnackShown = true;
    setState(() => _loading = false);
    final l10n = AppLocalizations.of(context)!;
    TopSnackBar.show(
      context,
      l10n.legalWebLoadError,
      type: TopSnackBarType.error,
      title: l10n.legalWebLoadErrorTitle,
    );
  }

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url.trim());
    final valid = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'https' || uri.scheme == 'http');

    if (!valid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showLoadErrorOnce();
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (WebResourceError error) {
            final main = error.isForMainFrame;
            if (main == false) return;
            _showLoadErrorOnce();
          },
          onHttpError: (HttpResponseError error) {
            final code = error.response?.statusCode;
            if (code != null && code >= 400) {
              _showLoadErrorOnce();
            }
          },
        ),
      )
      ..loadRequest(uri);

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return ColoredBox(
        color: Colors.white,
        child: _loading ? loader() : const SizedBox.shrink(),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: _controller!),
          ),
          if (_loading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.92),
                child: loader(),
              ),
            ),
        ],
      ),
    );
  }
}

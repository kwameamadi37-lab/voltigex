import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voltigex/core/config/app_remote_config.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/legal_web_view_page.dart';
import 'package:voltigex/l10n/app_localizations.dart';

const Color _kPageBg = Color(0xFFF5F6F8);
const Color _kSectionLabel = Color(0xFF6B7280);
const String _kDisplayAppVersion = '1.2.18';

class LegalDocumentationPage extends StatefulWidget {
  const LegalDocumentationPage({super.key});

  @override
  State<LegalDocumentationPage> createState() => _LegalDocumentationPageState();
}

class _LegalDocumentationPageState extends State<LegalDocumentationPage> {
  late Future<AppRemoteConfig> _configFuture = AppRemoteConfig.load();

  void _openLegalPage(BuildContext context, String title, String url) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegalWebViewPage(url: url, title: title),
      ),
    );
  }

  Future<void> _openPdf(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DefaultColors.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.legalPageTitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: DefaultColors.blackColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<AppRemoteConfig>(
                future: _configFuture,
                builder: (context, snapshot) {
                  final cfg = snapshot.data ?? AppRemoteConfig.fallback;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      _SectionLabel(title: l10n.legalSectionBrand),
                      _LegalCard(
                        children: [
                          _LegalRow(
                            title: l10n.legalRowPrivacy,
                            onTap: () => _openLegalPage(
                              context,
                              l10n.legalRowPrivacy,
                              cfg.privacyWebUrl ?? AppRemoteConfig.fallback.privacyWebUrl!,
                            ),
                            onDownload: cfg.privacyPdfUrl != null
                                ? () => _openPdf(cfg.privacyPdfUrl)
                                : null,
                          ),
                          _divider(),
                          _LegalRow(
                            title: l10n.legalRowTermsOfUse,
                            onTap: () => _openLegalPage(
                              context,
                              l10n.legalRowTermsOfUse,
                              cfg.termsWebUrl ?? AppRemoteConfig.fallback.termsWebUrl!,
                            ),
                            onDownload: cfg.termsPdfUrl != null
                                ? () => _openPdf(cfg.termsPdfUrl)
                                : null,
                          ),
                          _divider(),
                          _LegalRow(
                            title: l10n.legalRowSecurityPolicy,
                            onTap: () => _openLegalPage(
                              context,
                              l10n.legalRowSecurityPolicy,
                              cfg.securityWebUrl ?? AppRemoteConfig.fallback.securityWebUrl!,
                            ),
                            onDownload: cfg.securityPdfUrl != null
                                ? () => _openPdf(cfg.securityPdfUrl)
                                : null,
                          ),
                        ],
                      ),
                      if (cfg.openingHours != null && cfg.openingHours!.trim().isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionLabel(title: 'Horaires'),
                        _LegalCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                cfg.openingHours!,
                                style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          l10n.legalAppVersionLine(_kDisplayAppVersion),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _kSectionLabel,
          ),
        ),
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

Widget _divider() =>
    Divider(height: 1, thickness: 1, color: Colors.grey.shade100);

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.title,
    required this.onTap,
    this.onDownload,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DefaultColors.blueBackground.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: DefaultColors.blueBackground,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: DefaultColors.blackColor,
                    ),
                  ),
                ),
              ),
              if (onDownload != null)
                IconButton(
                  tooltip: 'PDF',
                  onPressed: onDownload,
                  icon: Icon(Icons.download_rounded, color: Colors.grey.shade600),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade500,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

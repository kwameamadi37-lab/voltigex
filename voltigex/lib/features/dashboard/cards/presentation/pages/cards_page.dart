import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/empty_transaction_state.dart';
import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_bloc.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_event.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_state.dart';
import 'package:voltigex/core/config/app_remote_config.dart';
import 'package:voltigex/core/config/card_catalog_entry.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Fond page cartes (Scaffold) — clair uniquement, jamais de filtre gris au-dessus.
const Color _kCardsBg = Color(0xFFF8F9FB);
const Color _kTextPrimary = Color(0xFF111827);

/// Textes / pictos / logo sur le visuel carte (Gold : blanc pur, pas de bleu ni noir).
const Color _kOnCardForegroundWhite = Color(0xFFFFFFFF);

String _cardsNumberFormatLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return 'fr_FR';
    case 'es':
      return 'es_ES';
    case 'de':
      return 'de_DE';
    case 'en':
    default:
      return 'en_US';
  }
}

NumberFormat _cardsMoneyFormat(BuildContext context) {
  return NumberFormat.currency(
    locale: _cardsNumberFormatLocale(Localizations.localeOf(context)),
    symbol: '€',
    decimalDigits: 2,
  );
}

/// Ombre légère pour texte / pictos blancs sur le visuel carte.
const List<Shadow> _kOnCardWhiteTextShadow = [
  Shadow(
    color: Color(0x99000000),
    offset: Offset(0, 1.5),
    blurRadius: 6,
  ),
];

/// `card_type` API → asset pleine carte (pas de dégradé ni blend : image seule).
abstract final class _CardTypeAssets {
  static const Map<String, String> imagePathByTier = {
    'gold': 'assets/images/card_gold.png',
    'diamond': 'assets/images/card_diamond.png',
    'platinum': 'assets/images/card_platinum.png',
  };

  static String pathForTier(String safeTier) =>
      imagePathByTier[safeTier] ?? imagePathByTier['platinum']!;
}

const String _kMaskedCardNumber = '**** **** **** ****';

String _normalizeCardTier(String cardType) {
  final tier = cardType.toLowerCase().trim();
  if (tier.contains('gold')) return 'gold';
  if (tier.contains('diamond')) return 'diamond';
  return 'platinum';
}

Color _tierHeaderBadgeColor(String tier) {
  switch (_normalizeCardTier(tier)) {
    case 'gold':
      return const Color(0xFFB45309);
    case 'diamond':
      return const Color(0xFF4F46E5);
    default:
      return const Color(0xFF475569);
  }
}

String _cardTierLabel(BuildContext context, String tier, {AppRemoteConfig? remoteConfig}) {
  final lang = Localizations.localeOf(context).languageCode;
  final fromApi = remoteConfig?.labelForCardTier(tier, lang);
  if (fromApi != null && fromApi.isNotEmpty) {
    return fromApi;
  }
  final l10n = AppLocalizations.of(context)!;
  switch (_normalizeCardTier(tier)) {
    case 'gold':
      return l10n.cardsTierGold;
    case 'diamond':
      return l10n.cardsTierDiamond;
    default:
      return l10n.cardsTierPlatinum;
  }
}

/// Ombres portées sous la carte selon le type (seul vestige « couleur » par tier).
abstract final class _CardTierStyle {
  static Color fallbackBackground(String tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFB45309);
      case 'diamond':
        return const Color(0xFF312e81);
      default:
        return const Color(0xFF334155);
    }
  }

  static List<BoxShadow> shadows(String tier) {
    switch (tier) {
      case 'gold':
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 52,
            spreadRadius: -2,
            offset: const Offset(0, 32),
          ),
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.28),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];
      case 'diamond':
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 52,
            spreadRadius: -2,
            offset: const Offset(0, 32),
          ),
          BoxShadow(
            color: const Color(0xFF312e81).withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 52,
            spreadRadius: -2,
            offset: const Offset(0, 32),
          ),
          BoxShadow(
            color: const Color(0xFF334155).withValues(alpha: 0.28),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];
    }
  }

}

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardExpDateController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  /// Transactions spécifiques à la carte (mock vide → état illustré « globe »).
  static const List<void> _cardTransactions = [];
  bool _didPrecacheCardBackgrounds = false;
  AppRemoteConfig? _remoteConfig;

  /// Type choisi avant activation (modale ou badge) — conservé après fermeture de la modale.
  String? _preferredCardType;

  @override
  void initState() {
    super.initState();
    AppRemoteConfig.load().then((config) {
      if (mounted) {
        setState(() => _remoteConfig = config);
      }
    });
  }

  List<CardCatalogEntry> get _activationCatalog =>
      _remoteConfig?.enabledCardCatalog ?? AppRemoteConfig.fallback.enabledCardCatalog;

  double _catalogAmountFor(String tierKey) {
    for (final entry in _activationCatalog) {
      if (entry.key == tierKey) return entry.amount;
    }
    return _remoteConfig?.amountForCardTier(tierKey) ?? 0;
  }

  String _cardTypeOptionLabel(
    BuildContext context,
    CardCatalogEntry entry,
    String languageCode,
  ) {
    final name = entry.labelForLocale(languageCode);
    if (entry.amount <= 0) return name;
    return '$name · ${_cardsMoneyFormat(context).format(entry.amount)}';
  }

  double _displayBalanceForCard(CardEntity card) {
    if (card.isActive && card.balance > 0) {
      return card.balance;
    }
    final fromCatalog = _catalogAmountFor(card.cardType);
    if (fromCatalog > 0) return fromCatalog;
    return card.balance;
  }

  String _effectiveDisplayCardType(CardEntity card) {
    if (card.isActive || card.isPending) {
      return _normalizeCardTier(card.cardType);
    }
    return _preferredCardType ?? _normalizeCardTier(card.cardType);
  }

  bool _canEditCardTypeBeforeActivation(CardEntity card) {
    return !card.isActive && !card.isPending;
  }

  Widget _tierBackgroundImage(String safeTier) {
    final url = _remoteConfig?.imageUrlForCardTier(safeTier);
    final assetPath = _CardTypeAssets.pathForTier(safeTier);
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Image.asset(
          assetPath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheCardBackgrounds) return;
    final uniquePaths = _CardTypeAssets.imagePathByTier.values.toSet();
    for (final path in uniquePaths) {
      precacheImage(AssetImage(path), context);
    }
    _didPrecacheCardBackgrounds = true;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpDateController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _snackFrozen(String message) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    TopSnackBar.show(
      context,
      message,
      type: TopSnackBarType.error,
      title: l10n.cardsSnackTitle,
    );
  }

  Future<void> _onPullRefreshCards(BuildContext context) async {
    final bloc = context.read<CardsBloc>();
    final nextLoaded = bloc.stream.firstWhere((s) => s is CardsLoaded);
    bloc.add(RefreshCardsData(forceRefresh: true));
    try {
      await nextLoaded.timeout(const Duration(seconds: 45));
    } on TimeoutException {
      // Ferme le [RefreshIndicator] même si l’API ne répond pas.
    }
  }

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
    final l10n = AppLocalizations.of(context)!;
    TopSnackBar.show(
      context,
      l10n.cardsCopiedBody(label),
      type: TopSnackBarType.success,
      title: l10n.cardsCopiedTitle,
      durationSeconds: 2,
    );
  }

  void _showBeforeYouAddMoneySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          l10n.cardsAddMoneyTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: _kTextPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            l10n.cardsAddMoneyBody,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: DefaultColors.blueBackground,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.cardsUnderstood,
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.grey.shade200,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(sheetContext).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCardDetailsSheet(CardEntity card) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.cardsDetailsTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _detailCopyRow(
                      ctx,
                      label: l10n.cardsFieldNumber,
                      value: card.numberDisplay,
                    ),
                    const SizedBox(height: 16),
                    _detailCopyRow(
                      ctx,
                      label: l10n.cardsFieldCvc,
                      value: card.cvc,
                    ),
                    const SizedBox(height: 16),
                    _detailCopyRow(
                      ctx,
                      label: l10n.cardsFieldExpiry,
                      value: card.expiryDisplay,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailCopyRow(
    BuildContext sheetContext, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kCardsBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copy(sheetContext, label, value),
            icon: Icon(Icons.copy_rounded, color: Colors.grey.shade700),
            tooltip: AppLocalizations.of(sheetContext)!.cardsCopyTooltip,
          ),
        ],
      ),
    );
  }

  void _showMoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return BlocBuilder<CardsBloc, CardsState>(
          buildWhen: (prev, curr) {
            if (curr is! CardsLoaded) return false;
            if (prev is! CardsLoaded) return true;
            final a = prev.primaryCard;
            final b = curr.primaryCard;
            return a?.isFrozen != b?.isFrozen ||
                prev.cardActionLoading != curr.cardActionLoading;
          },
          builder: (context, state) {
            if (state is! CardsLoaded) {
              return const SizedBox.shrink();
            }
            final c = state.primaryCard;
            if (c == null) return const SizedBox.shrink();
            final busy = state.cardActionLoading;
            final l10n = AppLocalizations.of(context)!;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: _moreOptionTile(
                          key: ValueKey<String>(
                            '${c.isFrozen}_${c.id}',
                          ),
                          icon: c.isFrozen
                              ? Icons.wb_sunny_outlined
                              : Icons.ac_unit_rounded,
                          iconColor: c.isFrozen
                              ? Colors.orange.shade700
                              : DefaultColors.blueBackground,
                          title: c.isFrozen
                              ? l10n.cardsUnfreeze
                              : l10n.cardsFreeze,
                          onTap: busy
                              ? () {}
                              : () {
                                  context
                                      .read<CardsBloc>()
                                      .add(ToggleCardFreeze());
                                },
                          enabled: !busy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _moreOptionTile({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? iconColor : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: enabled ? _kTextPrimary : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardTypePicker(CardEntity card) {
    if (!_canEditCardTypeBeforeActivation(card)) return;
    final catalog = _activationCatalog;
    if (catalog.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    var current = _effectiveDisplayCardType(card);
    if (catalog.every((e) => e.key != current)) {
      current = catalog.first.key;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.cardsActivateTypeLabel,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              for (final entry in catalog)
                ListTile(
                  title: Text(
                    _cardTypeOptionLabel(sheetContext, entry, lang),
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  trailing: current == entry.key
                      ? Icon(Icons.check_circle, color: DefaultColors.blueBackground)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (!mounted) return;
                    setState(() => _preferredCardType = entry.key);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showActivateDialog(CardEntity card) {
    _cardHolderController.text = card.holderName;
    _cardNumberController.text = '';
    final exp = card.expiryDisplay;
    _cardExpDateController.text = exp.length >= 4
        ? '${exp.substring(0, 2)}/${exp.substring(exp.length - 2)}'
        : exp;
    _cardCvvController.text = card.cvc;

    final catalog = _activationCatalog;
    var selectedType = _effectiveDisplayCardType(card);
    if (catalog.every((e) => e.key != selectedType)) {
      selectedType = catalog.isNotEmpty ? catalog.first.key : 'platinum';
    }

    setState(() => _preferredCardType = selectedType);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        final lang = Localizations.localeOf(dialogContext).languageCode;
        return StatefulBuilder(
          builder: (context, setDialogState) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cardsActivateDialogTitle,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: DefaultColors.blueBackground,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade700,
                          ),
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _kTextPrimary,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.cardsActivateTypeLabel,
                            labelStyle: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: DefaultColors.blueBackground,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            for (final entry in catalog)
                              DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(
                                  _cardTypeOptionLabel(
                                    dialogContext,
                                    entry,
                                    lang,
                                  ),
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _kTextPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          selectedItemBuilder: (context) {
                            return [
                              for (final entry in catalog)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _cardTypeOptionLabel(
                                      dialogContext,
                                      entry,
                                      lang,
                                    ),
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _kTextPrimary,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ];
                          },
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() => selectedType = value);
                            if (mounted) {
                              setState(() => _preferredCardType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: DefaultColors.blueBackground.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DefaultColors.blueBackground.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 22,
                                color: DefaultColors.blueBackground.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.cardsActivateAmountLabel,
                                  style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                _cardsMoneyFormat(dialogContext).format(
                                  _catalogAmountFor(selectedType),
                                ),
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: DefaultColors.blueBackground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        BuildLabeledTextField(
                          label: l10n.cardsHolderLabel,
                          hintText: l10n.cardsHolderHint,
                          controller: _cardHolderController,
                          isEditable: false,
                        ),
                        const SizedBox(height: 15),
                        BuildLabeledTextField(
                          label: l10n.cardsNumberLabel,
                          hintText: l10n.cardsNumberHint,
                          controller: _cardNumberController,
                          inputType: TextInputType.number,
                          isEditable: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.cardsFieldMandatory;
                            }
                            final n = value.replaceAll(' ', '').length;
                            if (n < 16 || n > 19) {
                              return l10n.cardsNumberInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(dialogContext).size.width * 0.4,
                              child: BuildLabeledTextField(
                                label: l10n.cardsExpiryLabel,
                                hintText: l10n.cardsExpiryHint, // Exemple: "MM/AA"
                                controller: _cardExpDateController,
                                isEditable: true,
                                isCardExpiryField: true,
                              )
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: BuildLabeledTextField(
                                label: l10n.cardsCvvLabel,
                                hintText: l10n.cardsCvvHint,
                                controller: _cardCvvController,
                                inputType: TextInputType.number,
                                isEditable: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FormsButton(
                          text: l10n.cardsActivateButton,
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (selectedType.isEmpty) {
                                TopSnackBar.show(
                                  dialogContext,
                                  l10n.cardsActivateTypeRequired,
                                  type: TopSnackBarType.error,
                                );
                                return;
                              }
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(dialogContext);
                                context.read<CardsBloc>().add(
                                      ActivateCard(
                                        cardHolder: _cardHolderController.text,
                                        cardNumber: _cardNumberController.text,
                                        dateExp: _cardExpDateController.text,
                                        cvv: _cardCvvController.text,
                                        cardType: selectedType,
                                      ),
                                    );
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final l10n = AppLocalizations.of(context)!;
  //   return BlocBuilder<CardsBloc, CardsState>(
  //     builder: (context, state) {
  //         print("xxxxxxxxxxxxx 111 a");
  //       if (state is CardsLoading || state is CardsInitial) {
          
  //         print("xxxxxxxxxxxxx 333 b");
  //         return Scaffold(
  //           backgroundColor: _kCardsBg,
  //           body: loader(),
  //         );
  //       }
  //       if (state is CardsError) {
  //         print("xxxxxxxxxxxxx 222 c");
  //         return Scaffold(
  //           backgroundColor: _kCardsBg,
  //           body: Center(
  //             child: Padding(
  //               padding: const EdgeInsets.all(24),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     state.message,
  //                     textAlign: TextAlign.center,
  //                     style: GoogleFonts.inter(),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   FilledButton(
  //                     onPressed: () =>
  //                         context.read<CardsBloc>().add(FetchCardsData()),
  //                     child: Text(l10n.buttonRetry),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       }

  //       if (state is CardsActivationDemandError) {
  //         print("xxxxxxxxxxxxx 222 e");
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (!mounted) return;
  //           TopSnackBar.show(
  //             context,
  //             l10n.cardsActivationDemandSuccessMessage,
  //             type: TopSnackBarType.success,
  //             title: "Magnifique",
  //           );
  //         });
  //       } else {


  //         print("xxxxxxxxxxxxx 222 d");
  //         final loaded = state as CardsLoaded;
  //         final card = loaded.primaryCard;
  //         if (card == null) {
  //           return Scaffold(
  //             backgroundColor: _kCardsBg,
  //             body: Center(
  //               child: Text(
  //                 l10n.cardsNone,
  //                 style: GoogleFonts.inter(),
  //               ),
  //             ),
  //           );
  //         }

        
  //         print("xxxxxxxxxxxxx 222 f");
  //         return _buildCardsContent(context, loaded);
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CardsBloc, CardsState>(
      // 1. LE LISTENER : Gère TOUS les effets de bord (SnackBars, Dialogs, Navigation)
      listener: (context, state) {
        if (state is CardsLoaded) {
          if (state.cardsActivationDemandSucess == true) {
            setState(() => _preferredCardType = null);
            TopSnackBar.show(
              context,
              l10n.cardsActivationDemandSuccessMessage,
              type: TopSnackBarType.success,
              title: "Magnifique",
            );
          }
        }

        if (state is CardsActivationDemandError) {
          TopSnackBar.show(
            context,
            l10n.cardsActivationDemandErrorMessage,
            type: TopSnackBarType.error,
            title: "Oups",
          );
        }
      },

      // 2. LE BUILDER : Détermine uniquement ce qui est affiché à l'écran
      builder: (context, state) {
        if (state is CardsLoading || state is CardsInitial) {
          return Scaffold(
            backgroundColor: _kCardsBg,
            body: loader(),
          );
        }

        if (state is CardsError) {
          return Scaffold(
            backgroundColor: _kCardsBg,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<CardsBloc>().add(FetchCardsData()),
                      child: Text(l10n.buttonRetry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is CardsLoaded) {
          final card = state.primaryCard;
          if (card == null) {
            return Scaffold(
              backgroundColor: _kCardsBg,
              body: Center(
                child: Text(
                  l10n.cardsNone,
                  style: GoogleFonts.inter(),
                ),
              ),
            );
          }

          return _buildCardsContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCardsContent(BuildContext context, CardsLoaded loaded) {
    final l10n = AppLocalizations.of(context)!;
    final card = loaded.primaryCard!;
    final w = MediaQuery.sizeOf(context).width;
    final cardW = (w - 48).clamp(280.0, 360.0);
    final cardH = cardW * 0.63;

    final canEditType = _canEditCardTypeBeforeActivation(card);
    final displayCardType = _effectiveDisplayCardType(card);
    final displayBalance = canEditType && _preferredCardType != null
        ? _catalogAmountFor(displayCardType)
        : _displayBalanceForCard(card.copyWith(cardType: displayCardType));
    final tierLabel = _cardTierLabel(
      context,
      displayCardType,
      remoteConfig: _remoteConfig,
    );
    final balanceFormatted = _cardsMoneyFormat(context).format(displayBalance);

    return Scaffold(
      backgroundColor: _kCardsBg,
      body: RefreshIndicator(
        onRefresh: () => _onPullRefreshCards(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
        child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canEditType
                              ? () => _showCardTypePicker(card)
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _tierHeaderBadgeColor(displayCardType),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _tierHeaderBadgeColor(displayCardType)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${tierLabel.toUpperCase()} · $balanceFormatted',
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: _kOnCardForegroundWhite,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (canEditType) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                    color: _kOnCardForegroundWhite,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showBeforeYouAddMoneySheet,
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 28,
                    ),
                    tooltip: l10n.cardsInfoTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Ombres hors ColorFiltered (voir _buildVoltigexCardVisual).
              AbsorbPointer(
                absorbing: loaded.cardActionLoading,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildVoltigexCardVisual(
                      cardW,
                      cardH,
                      cardType: displayCardType,
                      showTierBadge: card.isActive && !card.isFrozen,
                      tierBadgeLabel: tierLabel,
                      dimmed: !card.isActive || card.isFrozen,
                      brandLabel: l10n.cardsBrandVoltigex,
                      holderLabel: l10n.cardsHolderLabel,
                      expiryLabel: l10n.cardsExpiryLabel,
                      holderName: card.holderName,
                      cardNumber: _kMaskedCardNumber,
                      expiry: card.expiryDisplay,
                      balanceText: balanceFormatted,
                      onDetailsTap: (!card.isActive || loaded.cardActionLoading)
                          ? null
                          : () {
                              if (card.isFrozen) {
                                _snackFrozen(l10n.cardsUnfreezeForDetails);
                                return;
                              }
                              _showCardDetailsSheet(card);
                            },
                      detailsTooltip: l10n.cardsActionSeeDetails,
                    ),
                    if (loaded.cardActionLoading)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: loader(compact: true),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!card.isActive && !card.isPending) ...[
                const SizedBox(height: 20),
                _buildActivateButton(context, card),
              ],
              const SizedBox(height: 28),
              if (card.isActive) _buildActionRow(context, card, loaded),
              const SizedBox(height: 52),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.cardsTransactionsTitle,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DefaultColors.blackColor,
                      ),
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.of(context, rootNavigator: false).push(
                  //       MaterialPageRoute<void>(
                  //         builder: (_) => const TransfersHistoryPage(),
                  //       ),
                  //     );
                  //   },
                  //   style: TextButton.styleFrom(
                  //     foregroundColor: DefaultColors.blueBackground,
                  //     padding: EdgeInsets.zero,
                  //     minimumSize: Size.zero,
                  //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   ),
                  //   child: Text(
                  //     'Voir tout',
                  //     style: GoogleFonts.inter(
                  //       textStyle: const TextStyle(
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              _cardTransactions.isEmpty
                  ? EmptyTransactionState(
                      message: l10n.cardsTransactionsEmpty,
                      variant: EmptyTransactionVariant.standaloneCard,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCardTierBadge(String tier, String label, double cardW) {
    final Color accent;
    switch (tier) {
      case 'gold':
        accent = const Color(0xFFFBBF24);
      case 'diamond':
        accent = const Color(0xFFA5B4FC);
      default:
        accent = const Color(0xFFCBD5E1);
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: cardW * 0.028,
        vertical: cardW * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.95), width: 1.2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: cardW * 0.032,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: _kOnCardForegroundWhite,
            shadows: _kOnCardWhiteTextShadow,
          ),
        ),
      ),
    );
  }

  /// Carte VOLTIGEX : perspective [Matrix4] + ombre hors filtre.
  /// Le [ColorFiltered] ne doit envelopper que le visage (clip), pas les [BoxShadow],
  /// sinon le flou d’ombre est saturé en gris sur tout l’écran.
  Widget _buildVoltigexCardVisual(
    double cardW,
    double cardH, {
    required String cardType,
    required bool showTierBadge,
    required String tierBadgeLabel,
    required bool dimmed,
    required String brandLabel,
    required String holderLabel,
    required String expiryLabel,
    required String holderName,
    required String cardNumber,
    required String expiry,
    required String balanceText,
    VoidCallback? onDetailsTap,
    String? detailsTooltip,
  }) {
    const radius = 16.0;
    final br = BorderRadius.circular(radius);
    final safeTier = _normalizeCardTier(cardType);
    final fallbackColor = _CardTierStyle.fallbackBackground(safeTier);

    Widget buildTierFace() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey<String>(safeTier),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: fallbackColor,
                ),
              ),
              Positioned.fill(
                child: _tierBackgroundImage(safeTier),
              ),
              Positioned(
                left: 16,
                top: 14,
                child: Text(
                  brandLabel,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: cardW * 0.04,
                      fontWeight: FontWeight.w700,
                      color: _kOnCardForegroundWhite,
                      letterSpacing: 1.2,
                      shadows: _kOnCardWhiteTextShadow,
                    ),
                  ),
                ),
              ),
              if (showTierBadge)
                Positioned(
                  left: 16,
                  top: cardH * 0.11,
                  child: _buildCardTierBadge(safeTier, tierBadgeLabel, cardW),
                ),
              Positioned(
                right: 16,
                top: 10,
                child: onDetailsTap == null
                    ? const SizedBox.shrink()
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onDetailsTap,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Tooltip(
                              message: detailsTooltip ?? '',
                              child: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                                color: _kOnCardForegroundWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: 16,
                top: cardH * 0.18,
                child: Text(
                  balanceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: cardW * 0.105,
                      fontWeight: FontWeight.w700,
                      color: _kOnCardForegroundWhite,
                      letterSpacing: -0.4,
                      shadows: _kOnCardWhiteTextShadow,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardNumber,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: cardW * 0.048,
                          fontWeight: FontWeight.w600,
                          color: _kOnCardForegroundWhite,
                          letterSpacing: 1.1,
                          shadows: _kOnCardWhiteTextShadow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Opacity(
                          opacity: 0.44,
                          child: Text(
                            holderLabel,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: cardW * 0.024,
                                fontWeight: FontWeight.w500,
                                color: _kOnCardForegroundWhite,
                                shadows: _kOnCardWhiteTextShadow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          holderName.toUpperCase(),
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: cardW * 0.032,
                              fontWeight: FontWeight.w600,
                              color: _kOnCardForegroundWhite,
                              letterSpacing: 0.3,
                              shadows: _kOnCardWhiteTextShadow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Opacity(
                          opacity: 0.44,
                          child: Text(
                            expiryLabel,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: cardW * 0.024,
                                fontWeight: FontWeight.w500,
                                color: _kOnCardForegroundWhite,
                                shadows: _kOnCardWhiteTextShadow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expiry,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: cardW * 0.032,
                              fontWeight: FontWeight.w600,
                              color: _kOnCardForegroundWhite,
                              letterSpacing: 0.3,
                              shadows: _kOnCardWhiteTextShadow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 14,
                child: SvgPicture.asset(
                  'assets/images/svg/visa.svg',
                  width: cardW * 0.18,
                  colorFilter: const ColorFilter.mode(
                    _kOnCardForegroundWhite,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final clippedFace = ClipRRect(
      borderRadius: br,
      child: buildTierFace(),
    );

    final clippedDimmedFace = ClipRRect(
      borderRadius: br,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: Opacity(
          opacity: 0.72,
          child: clippedFace,
        ),
      ),
    );

    Widget buildTransformCard() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: br,
          boxShadow: _CardTierStyle.shadows(safeTier),
        ),
        child: dimmed ? clippedDimmedFace : clippedFace,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: cardH * 0.010,
        bottom: cardH * 0.12,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey<bool>(dimmed),
            child: buildTransformCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildActivateButton(BuildContext context, CardEntity card) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showActivateDialog(card),
        child: Ink(
          decoration: BoxDecoration(
            color: DefaultColors.blueBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563eb).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                l10n.cardsActivateButton,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, CardEntity card, CardsLoaded loaded) {
    final l10n = AppLocalizations.of(context)!;
    final busy = loaded.cardActionLoading;

    Widget circleAction({
      required String label,
      required Widget child,
      required VoidCallback onTap,
      // Libellé à 0.4 si carte gelée (pas d’AnimatedOpacity sur toute la colonne).
      required bool applyFrozenLabelOpacity,
    }) {
      return Expanded(
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: child,
              ),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: applyFrozenLabelOpacity && card.isFrozen ? 0.4 : 1.0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        circleAction(
          label: l10n.cardsActionAddMoney,
          applyFrozenLabelOpacity: true,
          onTap: () {},

          // Cursor: ne pas décommenter
          // onTap: busy
          //     ? () {}
          //     : () {
          //         if (card.isFrozen) {
          //           _snackFrozen(
          //             'Dégeler la carte pour effectuer cette opération',
          //           );
          //           return;
          //         }
          //         context.read<CardsBloc>().add(AddMoneyToCard(amount: 100));
          //         getSnackBar(
          //           titleText: 'Ajouter de l\'argent',
          //           messageText:
          //               'Demande enregistrée (solde carte affiché à 0).',
          //           displayFor: 2,
          //         );
          //       },
          
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: (card.isFrozen || busy)
              //     ? Colors.grey.shade200
              //     : DefaultColors.blueBackground,
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: (card.isFrozen || busy) ? 0.04 : 0.12,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              // color: (card.isFrozen || busy)
              //     ? Colors.grey
              //     : Colors.white,
              color:Colors.grey,
              size: 28,
            ),
          ),
        ),
        circleAction(
          label: l10n.cardsActionSeeDetails,
          applyFrozenLabelOpacity: true,
          onTap: busy
              ? () {}
              : () {
                  if (card.isFrozen) {
                    _snackFrozen(
                      l10n.cardsUnfreezeForDetails,
                    );
                    return;
                  }
                  _showCardDetailsSheet(card);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (card.isFrozen || busy)
                  ? Colors.grey.shade200
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: (card.isFrozen || busy) ? 0.04 : 0.08,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.visibility_outlined,
              color: (card.isFrozen || busy)
                  ? Colors.grey
                  : DefaultColors.blueBackground,
              size: 26,
            ),
          ),
        ),
        circleAction(
          label: l10n.cardsMore,
          applyFrozenLabelOpacity: false,
          onTap: busy ? () {} : _showMoreSheet,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: DefaultColors.blueBackground,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';
import 'package:voltigex/features/dashboard/domain/entities/recent_recipient_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/transfer_repository.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/empty_transaction_state.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_chat_tab_opener.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_event.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_state.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/widgets/transfer_info_row.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Réduit la sensibilité au tirage vertical (pull-to-refresh moins « sec »).
class _RecentPullScrollPhysics extends ScrollPhysics {
  const _RecentPullScrollPhysics({super.parent});

  @override
  _RecentPullScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _RecentPullScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * 0.55);
  }
}

/// Scroll principal de la page virement : toujours scrollable (pull refresh) + inertie atténuée.
ScrollPhysics _makeTransferPageScrollPhysics() => AlwaysScrollableScrollPhysics(
  parent: _RecentPullScrollPhysics(parent: BouncingScrollPhysics()),
);

/// Jauge alignée sur `pourcentage` API : 3,5 s par transition, mouvement rapide puis ralenti.
class _TransferProgressGauge extends StatefulWidget {
  const _TransferProgressGauge({
    super.key,
    required this.apiPercent,
    required this.onClose,
    required this.l10n,
  });

  final double apiPercent;
  final VoidCallback onClose;
  final AppLocalizations l10n;

  @override
  State<_TransferProgressGauge> createState() => _TransferProgressGaugeState();
}

class _TransferProgressGaugeState extends State<_TransferProgressGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _animation;
  double _display = 0;

  /// Tant que l’API n’a pas remonté de pourcentage (> 0), on affiche un cercle
  /// **indéterminé** : sinon (ex. code invalide en réessai) une seule émission
  /// `progressPercent: 0` ne déclenche aucun tween et la jauge reste figée.
  bool _awaitingRealProgress = false;

  /// Durée max d’une transition 0→100 % (×3 par rapport à l’ancienne ~3,5 s).
  static const int _maxSweepMs = 14000;
  static const Curve _curve = Cubic(0.22, 0.92, 0.18, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _maxSweepMs),
    );
    _controller.addListener(_onTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _display = widget.apiPercent.clamp(0, 100).toDouble();
        });
      }
    });
    _controller.reset();
    _animation = null;
    final initial = widget.apiPercent.clamp(0, 100).toDouble();
    if (initial > 0.009) {
      _awaitingRealProgress = false;
      _display = 0;
      _runTween(0, initial);
    } else {
      _awaitingRealProgress = true;
      _display = 0;
    }
  }

  void _onTick() {
    if (_animation != null) {
      setState(() => _display = _animation!.value);
    }
  }

  void _runTween(double from, double to) {
    final a = from.clamp(0, 100).toDouble();
    final b = to.clamp(0, 100).toDouble();
    if ((a - b).abs() < 0.01) {
      setState(() => _display = b);
      return;
    }
    final span = (b - a).abs();
    final ms =
        (span / 100.0 * _maxSweepMs).round().clamp(400, _maxSweepMs);
    _controller.duration = Duration(milliseconds: ms);
    _controller.stop();
    _controller.reset();
    _animation = Tween<double>(
      begin: a,
      end: b,
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _TransferProgressGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.apiPercent.clamp(0, 100).toDouble();
    final prev = oldWidget.apiPercent.clamp(0, 100).toDouble();
    if (_awaitingRealProgress && next > 0.009) {
      setState(() => _awaitingRealProgress = false);
      _runTween(0, next);
      return;
    }
    if (_awaitingRealProgress) return;
    if ((next - prev).abs() < 0.01) return;
    final from = _controller.isAnimating
        ? (_animation?.value ?? _display)
        : _display;
    _runTween(from, next);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indeterminate = _awaitingRealProgress && widget.apiPercent < 0.01;
    final value = (_display / 100).clamp(0.0, 1.0);
    final label = indeterminate
        ? '…'
        : '${_display.clamp(0, 100).toStringAsFixed(0)}%';
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.l10n.transferProgressTitle,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DefaultColors.blueBackground,
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onClose,
              child: const Icon(Icons.close, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 35),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 115,
                    width: 115,
                    child: indeterminate
                        ? CircularProgressIndicator(
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              DefaultColors.blueBackground,
                            ),
                          )
                        : CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              DefaultColors.blueBackground,
                            ),
                          ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.5,
                        color: DefaultColors.blackColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Text(
                widget.l10n.transferProgressSubtitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: DefaultColors.blackColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.l10n.transferProgressWait,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: DefaultColors.black2Color,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MakeTransferPage extends StatefulWidget {
  const MakeTransferPage({super.key});

  @override
  State<MakeTransferPage> createState() => _MakeTransferPageState();
}

class _MakeTransferPageState extends State<MakeTransferPage>
    with SingleTickerProviderStateMixin {
  /// Régénérée dans [_fullFormReset] pour éviter que [FormState.reset] réinjecte d’anciennes valeurs.
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _validationCodeController =
      TextEditingController();

  bool _progressDialogVisible = false;
  DateTime? _loaderShownAt;
  int _loaderSession = 0;

  /// Complété lorsque la route du dialogue de progression est fermée ([Navigator.pop]).
  Future<void>? _progressDialogClosedFuture;
  late TabController _tabController;
  List<RecentRecipientEntity> _recipients = [];
  bool _recipientsLoading = true;
  bool _recipientsHasMore = false;
  bool _recipientsLoadingMore = false;
  int _recipientsNextPageToLoad = 2;
  bool _isRetryMode = false;
  int? _retryVirementId;

  static const int _recentRecipientsPageSize = 25;

  List<String> _transferTabLabels(AppLocalizations l) =>
      [l.transferTabRecent, l.transferTabNew];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
    _loadRecipients();
  }

  static const int _recipientsMinLoadMs = 1200;
  static const int _recipientsMinPullRefreshMs = 900;

  /// [fromPullRefresh] : pas d’écran de chargement plein ; durée mini pour calmer le [RefreshIndicator].
  Future<void> _loadRecipients({bool fromPullRefresh = false}) async {
    if (!fromPullRefresh) {
      setState(() => _recipientsLoading = true);
    }
    final sw = Stopwatch()..start();
    final minMs =
        fromPullRefresh ? _recipientsMinPullRefreshMs : _recipientsMinLoadMs;
    try {
      final page = await sl<TransferRepository>().fetchRecentRecipients(
        page: 1,
        perPage: _recentRecipientsPageSize,
      );
      final left = minMs - sw.elapsedMilliseconds;
      if (left > 0) {
        await Future<void>.delayed(Duration(milliseconds: left));
      }
      if (mounted) {
        setState(() {
          _recipients = page.items;
          _recipientsHasMore = page.hasMore;
          _recipientsNextPageToLoad = page.hasMore ? page.currentPage + 1 : 2;
          _recipientsLoading = false;
          _recipientsLoadingMore = false;
        });
      }
    } catch (_) {
      final left = minMs - sw.elapsedMilliseconds;
      if (left > 0) {
        await Future<void>.delayed(Duration(milliseconds: left));
      }
      if (mounted) {
        setState(() {
          _recipients = [];
          _recipientsHasMore = false;
          _recipientsNextPageToLoad = 2;
          _recipientsLoading = false;
          _recipientsLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreRecipients() async {
    if (_recipientsLoadingMore || !_recipientsHasMore || _recipientsLoading) {
      return;
    }
    setState(() => _recipientsLoadingMore = true);
    try {
      final page = await sl<TransferRepository>().fetchRecentRecipients(
        page: _recipientsNextPageToLoad,
        perPage: _recentRecipientsPageSize,
      );
      if (!mounted) return;
      setState(() {
        _recipients.addAll(page.items);
        _recipientsHasMore = page.hasMore;
        if (page.hasMore) {
          _recipientsNextPageToLoad = page.currentPage + 1;
        }
        _recipientsLoadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _recipientsLoadingMore = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _bankNameController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _amountController.dispose();
    _validationCodeController.dispose();
    super.dispose();
  }

  /// Dialog de progression : même structure visuelle ; la valeur du cercle suit [TransferSubmitting.progressPercent].
  void _showCircularProgression(TransferBloc bloc) {
    _loaderShownAt = DateTime.now();
    _loaderSession++;
    _progressDialogClosedFuture =
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return BlocProvider.value(
              value: bloc,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.37,
                  child: Center(
                    child: BlocBuilder<TransferBloc, TransferState>(
                      buildWhen: (prev, curr) {
                        if (curr is! TransferSubmitting) return false;
                        if (prev is! TransferSubmitting) return true;
                        return prev.progressPercent != curr.progressPercent;
                      },
                      builder: (context, state) {
                        final apiPct = state is TransferSubmitting
                            ? state.progressPercent.clamp(0, 100).toDouble()
                            : 0.0;
                        return _TransferProgressGauge(
                          key: ValueKey(_loaderSession),
                          apiPercent: apiPct,
                          onClose: () => Navigator.pop(dialogContext),
                          l10n: AppLocalizations.of(dialogContext)!,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ).whenComplete(() {
          _progressDialogClosedFuture = null;
          if (mounted) {
            setState(() => _progressDialogVisible = false);
          }
        });
  }

  static const int _loaderFullSweepMs = 14000;
  static const int _loaderSuspenseAfterTargetSeconds = 4;
  static const int _loaderMinVisibleZeroProgressMs = 3200;

  /// Attend que la jauge ait eu le temps d’atteindre [finalProgressPercent], puis un suspense fixe.
  Future<void> _awaitLoaderAnimationAndSuspense(
    double finalProgressPercent,
  ) async {
    final start = _loaderShownAt;
    if (start == null) {
      await Future<void>.delayed(
        const Duration(seconds: _loaderSuspenseAfterTargetSeconds),
      );
      return;
    }
    final pct = finalProgressPercent.clamp(0.0, 100.0);
    final animMs = (pct / 100.0 * _loaderFullSweepMs).round();
    var elapsed = DateTime.now().difference(start).inMilliseconds;
    var waitAnim = animMs - elapsed;
    if (waitAnim < 0) {
      waitAnim = 0;
    }
    await Future<void>.delayed(Duration(milliseconds: waitAnim));

    if (pct < 0.01) {
      elapsed = DateTime.now().difference(start).inMilliseconds;
      final left = _loaderMinVisibleZeroProgressMs - elapsed;
      if (left > 0) {
        await Future<void>.delayed(Duration(milliseconds: left));
      }
    }

    await Future<void>.delayed(
      const Duration(seconds: _loaderSuspenseAfterTargetSeconds),
    );
  }

  void _resetTransferFormControllers() {
    _lastNameController.clear();
    _firstNameController.clear();
    _bankNameController.clear();
    _ibanController.clear();
    _bicController.clear();
    _amountController.clear();
    _validationCodeController.clear();
  }

  void _openTransferHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        final maxH = MediaQuery.sizeOf(sheetContext).height * 0.88;
        return Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
              child: Column(
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
                    l10n.transferUsefulInfoTitle,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.5,
                        color: DefaultColors.blueBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  transferInfoRow(
                    Icons.arrow_right_alt_outlined,
                    l10n.transferInfoDelay,
                  ),
                  const SizedBox(height: 8),
                  transferInfoRow(
                    Icons.calendar_today_outlined,
                    l10n.transferInfoScheduled,
                  ),
                  const SizedBox(height: 8),
                  transferInfoRow(
                    Icons.credit_score_rounded,
                    l10n.transferInfoIban,
                  ),
                  const SizedBox(height: 8),
                  transferInfoRow(
                    Icons.receipt_long_rounded,
                    l10n.transferInfoReceipt,
                  ),
                  const SizedBox(height: 15),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        openSupportChatInMainTab(context);
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFeff6ff),
                          borderRadius: BorderRadius.circular(5),
                          border: BoxBorder.all(
                            color: const Color(0xFFdbeafe),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.transferHelpTitle,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  color: DefaultColors.blueBackground,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.transferHelpBody,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: DefaultColors.greyText,
                                ),
                              ),
                            ),
                          ],
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

  /// Bottom sheet information / support ([context] = page, après fermeture du loader).
  /// Même ton visuel pour tout retour API virement (y compris `termine`) : aucun virement n’est traité comme réussi pour l’instant.
  Future<void> _showSupportModal(
    BuildContext context, {
    String? slug,
    bool insufficientBalance = false,
  }) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final hasCode = slug != null && slug.isNotEmpty;
    final supportCode =
        (slug != null && slug.isNotEmpty) ? slug.trim() : '';

    late final String title;
    late final String body;
    if (insufficientBalance) {
      title = l10n.transferInsufficientTitle;
      body = l10n.transferInsufficientBody;
    } else {
      title = l10n.transferSupportTitle;
      if (hasCode) {
        body = l10n.transferFailureBodyWithCode(supportCode);
      } else {
        body = l10n.transferFailureBodyNoCode;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
          child: SafeArea(
            top: false,
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
                const SizedBox(height: 20),
                Icon(
                  insufficientBalance
                      ? Icons.account_balance_wallet_outlined
                      : Icons.support_agent_rounded,
                  size: 52,
                  color: insufficientBalance
                      ? Colors.deepOrange.shade700
                      : DefaultColors.blueBackground,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DefaultColors.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                if (hasCode)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.transferModalClose,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: supportCode),
                            );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DefaultColors.blueBackground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.transferCopyCode,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.transferModalClose,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Nettoie tout l’état du formulaire (onglet Nouveau virement) et force un rebuild.
  void _fullFormReset() {
    FocusManager.instance.primaryFocus?.unfocus();
    _resetTransferFormControllers();
    setState(() {
      _formKey = GlobalKey<FormState>();
      _isRetryMode = false;
      _retryVirementId = null;
    });
  }

  String _normalizeErrorMessage(String message) {
    return message.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  /// Aligné sur le message API « Solde insuffisant pour ce virement ».
  bool _isInsufficientBalance(String message) {
    final m = message.toLowerCase();
    return m.contains('solde insuffisant') ||
        m.contains('insufficient balance');
  }

  String _maskIban(String iban) {
    final c = iban.replaceAll(' ', '');
    if (c.length <= 8) return iban;
    return '•••• •••• •••• ${c.substring(c.length - 4)}';
  }

  void _applyRecipient(RecentRecipientEntity r) {
    // Aucun virement n’est considéré comme définitivement réussi : toujours le flux réessai (code + id).
    if (r.virementId > 0) {
      _startRetry(r);
      return;
    }
    _firstNameController.text = r.firstName;
    _lastNameController.text = r.lastName;
    _bankNameController.text = r.bankName;
    _ibanController.text = r.iban;
    _bicController.text = r.bic ?? '';
    _amountController.text = r.amount > 0
        ? r.amount.toStringAsFixed(2)
        : _amountController.text;
    _validationCodeController.clear();
    setState(() {
      _isRetryMode = false;
      _retryVirementId = null;
    });
    _tabController.animateTo(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _startRetry(RecentRecipientEntity r) {
    _firstNameController.text = r.firstName;
    _lastNameController.text = r.lastName;
    _bankNameController.text = r.bankName;
    _ibanController.text = r.iban;
    _bicController.text = r.bic ?? '';
    _amountController.text = r.amount > 0 ? r.amount.toStringAsFixed(2) : '';
    _validationCodeController.clear();
    setState(() {
      _isRetryMode = true;
      _retryVirementId = r.virementId;
    });
    _tabController.animateTo(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onValidatePressed() {
    final l10n = AppLocalizations.of(context)!;
    final newTab = _transferTabLabels(l10n)[1];
    if (_tabController.index != 1) {
      TopSnackBar.show(
        context,
        l10n.transferSwitchTabForForm(newTab),
        type: TopSnackBarType.error,
        title: l10n.transferSnackTitle,
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      TopSnackBar.show(
        context,
        l10n.transferInvalidAmount,
        type: TopSnackBarType.error,
        title: l10n.transferSnackTitle,
      );
      return;
    }
    if (_isRetryMode && _retryVirementId == null) {
      TopSnackBar.show(
        context,
        l10n.transferRetryInvalid,
        type: TopSnackBarType.error,
        title: l10n.transferSnackTitle,
      );
      return;
    }
    final transferBloc = context.read<TransferBloc>();
    transferBloc.add(TransferUiReset());
    transferBloc.add(
      SubmitTransferRequested(
        MakeTransferParams(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          bankName: _bankNameController.text.trim(),
          iban: _ibanController.text.trim(),
          bic: _bicController.text.trim(),
          amount: amount,
          executionDateRaw: '',
          reason: '',
        ),
        retryVirementId: _isRetryMode ? _retryVirementId : null,
        validationCode: _isRetryMode
            ? _validationCodeController.text.trim()
            : null,
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _transferTabLabels(l10n);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: DefaultColors.receiverMessage,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _tabController.index == i;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _tabController.animateTo(
                    i,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                        color: sel
                            ? DefaultColors.blackColor
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  static int _recentListDelegateChildCount(int n) {
    if (n <= 0) return 0;
    return 2 * n - 1;
  }

  Widget _buildRecentRecipientTile(RecentRecipientEntity r) {
    final title = r.holderName.isNotEmpty ? r.holderName : r.bankName;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: ListTile(
        enabled: !r.isTerminalClosed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: DefaultColors.blackColor,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.bankName,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _maskIban(r.iban),
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: r.isTerminalClosed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${r.progressPercent.round()} %',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: DefaultColors.blueBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.listOutcomeLabel,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange.shade700,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${r.progressPercent.round()} %',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                              color: DefaultColors.blueBackground,
                            ),
                          ),
                        ),
                        Text(
                          r.listOutcomeLabel,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _startRetry(r),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: DefaultColors.whiteText,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.transferFinalize,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DefaultColors.whiteText,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: DefaultColors.blueBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
        onTap: r.isTerminalClosed ? null : () => _applyRecipient(r),
      ),
    );
  }

  /// Bloc sous les onglets pour « Récents » (slivers du [CustomScrollView] parent).
  List<Widget> _buildRecipientsSlivers(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const horizontal = 20.0;
    final hPad = const EdgeInsets.symmetric(horizontal: horizontal);
    if (_recipientsLoading) {
      return [
        SliverPadding(
          padding: hPad,
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: loader(),
            ),
          ),
        ),
      ];
    }
    if (_recipients.isEmpty) {
      final minH = (MediaQuery.sizeOf(context).height * 0.42).clamp(
        220.0,
        520.0,
      );
      return [
        SliverPadding(
          padding: hPad,
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minH),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: EmptyTransactionState(
                    message: l10n.transferNoRecentRecipients(
                      _transferTabLabels(l10n)[1],
                    ),
                    variant: EmptyTransactionVariant.standaloneCard,
                  ),
                ),
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: hPad,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index.isOdd) {
              return const SizedBox(height: 10);
            }
            final i = index ~/ 2;
            return _buildRecentRecipientTile(_recipients[i]);
          }, childCount: _recentListDelegateChildCount(_recipients.length)),
        ),
      ),
      if (_recipientsHasMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: _recipientsLoadingMore
                  ? SizedBox(
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: loader(compact: true),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _loadMoreRecipients,
                      child: Text(
                        l10n.transferSeeMore,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: DefaultColors.blueBackground,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
    ];
  }

  Widget _buildNewRecipientForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          if (!_isRetryMode) ...[
            BuildLabeledTextField(
              label: l10n.transferFieldLastName,
              hintText: l10n.transferHintLastName,
              controller: _lastNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.formValidatorFillField;
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            BuildLabeledTextField(
              label: l10n.transferFieldFirstName,
              hintText: l10n.transferHintFirstName,
              controller: _firstNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.formValidatorFillField;
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            BuildLabeledTextField(
              label: l10n.transferFieldBankName,
              hintText: l10n.transferHintBankName,
              controller: _bankNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.formValidatorFillField;
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            BuildLabeledTextField(
              label: l10n.transferFieldIban,
              hintText: l10n.transferHintIban,
              controller: _ibanController,
              isIbanField: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.formValidatorFillField;
                }
                if (value.replaceAll(' ', '').length < 15) {
                  return l10n.transferIbanInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            BuildLabeledTextField(
              label: l10n.transferFieldBic,
              isBicField: true,
              hintText: l10n.transferHintBic,
              controller: _bicController,
            ),
            const SizedBox(height: 15),
          ],
          BuildLabeledTextField(
            label: l10n.transferFieldAmount,
            hintText: l10n.transferHintAmount,
            controller: _amountController,
            suffix: '€',
            inputType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.formValidatorFillField;
              }
              return null;
            },
          ),
          if (_isRetryMode) ...[
            const SizedBox(height: 15),
            BuildLabeledTextField(
              label: l10n.transferFieldValidationCode,
              hintText: l10n.transferHintValidationCode,
              isCodeField: true,
              controller: _validationCodeController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.transferValidationCodeError;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 25),
          BlocBuilder<TransferBloc, TransferState>(
            buildWhen: (p, c) {
              final wasBusy = p is TransferSubmitting;
              final isBusy = c is TransferSubmitting;
              return wasBusy != isBusy;
            },
            builder: (context, state) {
              final busy = state is TransferSubmitting;
              return FormsButton(
                text: busy
                    ? l10n.transferSending
                    : _isRetryMode
                    ? l10n.transferFinalizeButton
                    : l10n.transferSubmitButton,
                onPressed: busy ? () {} : _onValidatePressed,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferBloc, TransferState>(
      listenWhen: (p, c) {
        if (c is TransferFailure || c is TransferSuccess) return true;
        if (c is TransferSubmitting && p is! TransferSubmitting) return true;
        return false;
      },
      listener: (context, state) async {
        final transferBloc = context.read<TransferBloc>();
        final rootNav = Navigator.of(context, rootNavigator: true);
        if (state is TransferSubmitting) {
          if (!_progressDialogVisible) {
            _progressDialogVisible = true;
            _showCircularProgression(transferBloc);
          }
        }
        if (state is TransferFailure) {
          final supportSlug = state.supportSlug;
          await _awaitLoaderAnimationAndSuspense(state.finalProgressPercent);
          if (!mounted) return;
          final dialogDone = _progressDialogClosedFuture;
          if (rootNav.canPop()) {
            rootNav.pop();
          }
          if (dialogDone != null) {
            await dialogDone;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (!mounted) return;
          final normalized = _normalizeErrorMessage(state.message);
          final insufficient = _isInsufficientBalance(normalized);

          if (insufficient) {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (!mounted) return;
          }

          if (!mounted) return;
          transferBloc.add(TransferUiReset());

          await Future<void>.delayed(const Duration(milliseconds: 400));
          if (!mounted || !context.mounted) return;
          await _showSupportModal(
            context,
            slug: supportSlug,
            insufficientBalance: insufficient,
          );

          if (!mounted) return;
          if (!insufficient) {
            const tabAnim = Duration(milliseconds: 320);
            _tabController.animateTo(
              0,
              duration: tabAnim,
              curve: Curves.easeOutCubic,
            );
            await Future<void>.delayed(
              tabAnim + const Duration(milliseconds: 40),
            );
            if (mounted) {
              setState(() {});
            }
            _fullFormReset();
            await _loadRecipients();
          }
        }
        if (state is TransferSuccess) {
          final tx = state.transaction;
          final finalPct =
              (tx.progressPercent ?? 0.0).clamp(0.0, 100.0).toDouble();
          await _awaitLoaderAnimationAndSuspense(finalPct);
          if (!mounted) return;
          final dialogDoneSuccess = _progressDialogClosedFuture;
          if (rootNav.canPop()) {
            rootNav.pop();
          }
          if (dialogDoneSuccess != null) {
            await dialogDoneSuccess;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;

          final apiSt = tx.apiStatut?.toLowerCase() ?? '';
          final showVirementOutcome =
              apiSt.isEmpty ||
              apiSt == 'en_cours' ||
              apiSt == 'en cours' ||
              apiSt == 'termine';

          if (!showVirementOutcome) {
            transferBloc.add(TransferUiReset());
            _fullFormReset();
            await _loadRecipients();
            return;
          }

          transferBloc.add(TransferUiReset());
          const tabAnim = Duration(milliseconds: 320);
          _tabController.animateTo(
            0,
            duration: tabAnim,
            curve: Curves.easeOutCubic,
          );
          await Future<void>.delayed(
            tabAnim + const Duration(milliseconds: 40),
          );
          if (mounted) {
            setState(() {});
          }
          _fullFormReset();
          await _loadRecipients();

          await Future<void>.delayed(const Duration(milliseconds: 350));
          if (!mounted || !context.mounted) return;
          await _showSupportModal(context, slug: tx.supportSlug);
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: RefreshIndicator(
            displacement: 40,
            strokeWidth: 3,
            onRefresh: () async {
              if (_tabController.index != 0) return;
              await _loadRecipients(fromPullRefresh: true);
            },
            child: CustomScrollView(
              physics: _makeTransferPageScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: DefaultColors.blackColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 22,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: l10n.transferUsefulInfoTitle,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: DefaultColors.blackColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _openTransferHelpSheet,
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.transferPageHeading,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: DefaultColors.blackColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTabBar(),
                        if (_tabController.index == 1) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _fullFormReset,
                              icon: const Icon(
                                Icons.restart_alt_outlined,
                                size: 20,
                                color: DefaultColors.whiteText,
                              ),
                              label: Text(
                                l10n.transferResetAll,
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.5,
                                    color: DefaultColors.whiteText,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                backgroundColor: DefaultColors.blueBackground,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else
                          const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (_tabController.index == 0)
                  ..._buildRecipientsSlivers(context),
                if (_tabController.index == 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(child: _buildNewRecipientForm()),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
          );
        },
      ),
    );
  }
}

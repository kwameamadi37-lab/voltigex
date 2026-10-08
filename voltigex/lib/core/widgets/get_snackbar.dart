import 'package:get/get.dart';
import 'package:voltigex/core/widgets/top_snackbar.dart';

/// Conservé pour compatibilité ; préférer [TopSnackBar.show] avec un [BuildContext].
void getSnackBar({
  bool isSucces = true,
  String titleText = '',
  String messageText = '',
  int displayFor = 7,
}) {
  final ctx = Get.key.currentContext;
  if (ctx == null || !ctx.mounted) return;
  TopSnackBar.show(
    ctx,
    messageText,
    type: isSucces ? TopSnackBarType.success : TopSnackBarType.error,
    title: titleText.isEmpty ? null : titleText,
    durationSeconds: displayFor,
  );
}

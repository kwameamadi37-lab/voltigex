import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:voltigex/core/locale/app_locale_storage.dart';

/// État : [Locale] active (persistée).
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(super.initial);

  Future<void> setLocale(Locale locale) async {
    final next = AppLocaleStorage.normalize(locale);
    if (next == state) return;
    emit(next);
    Get.updateLocale(next);
    await AppLocaleStorage.save(next);
  }
}

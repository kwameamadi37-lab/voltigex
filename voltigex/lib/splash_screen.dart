import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart'
    show ConversationsInboxCoordinator;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    final session = SessionController.instance;

    session.loadSession().then((_) async {
      if (session.userId != null && session.token != null && session.token!.isNotEmpty) {
        await SocketService().initSocket();
        await SocketService().subscribeUserInbox(
          session.userId!,
          ConversationsInboxCoordinator.onInboxPusherData,
        );
      }
      if (!context.mounted) return;
      if (session.userId == null) {
        Timer(const Duration(seconds: 2), () {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        });
      } else {
        Timer(const Duration(seconds: 2), () {
          if (!context.mounted) return;
          final next = session.isAdminSupport ? "/conversationPage" : "/navigationPage";
          Navigator.pushNamedAndRemoveUntil(context, next, (route) => false);
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loader(),
    );
  }
}

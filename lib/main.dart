import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/services/notification_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/stores/screens/owner/owner_dashboard_screen.dart';

// رقم هاتف الأدمن (أنت)
const String kAdminPhone = '0931805919';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تهيئة نظام الإشعارات
  final notificationService = NotificationService();
  await notificationService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AlaAinyApp());
}

class AlaAinyApp extends StatelessWidget {
  const AlaAinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      home: const SplashScreen(),
    );
  }
}

// AuthGate — يحدد نوع المستخدم بعد تسجيل الدخول
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
          );
        }

        if (!snapshot.hasData) return const AuthScreen();

        // تحديد نوع المستخدم
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)),
              );
            }

            final userData = userSnap.data?.data() as Map<String, dynamic>?;
            final phone = userData?['phone'] as String? ?? '';
            final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
            final cleanAdmin = kAdminPhone.replaceAll(RegExp(r'\D'), '');

            // أدمن → لوحة تحكم الأدمن
            if (cleanPhone == cleanAdmin) {
              return const DashboardScreen();
            }

            // صاحب متجر → لوحة تحكم المتجر
            return const OwnerDashboardScreen();
          },
        );
      },
    );
  }
}

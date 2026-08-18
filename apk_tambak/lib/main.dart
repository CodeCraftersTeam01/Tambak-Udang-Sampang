import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/network/api_client.dart';
import 'core/security/secure_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/datasources/kolam_remote_datasource.dart';
import 'data/repositories/kolam_repository_impl.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'presentation/bloc/kolam_bloc.dart';
import 'presentation/bloc/kolam_event.dart';
import 'presentation/ui/login_screen.dart';
import 'core/constants/app_colors.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'domain/entities/kolam_entity.dart';
import 'presentation/ui/pond_detail_screen.dart';
import 'presentation/bloc/kolam_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SecureStorage globalSecureStorage = SecureStorage();
late final ApiClient globalApiClient;

Future<void> _handleNotificationClick(RemoteMessage? message) async {
  if (message == null) return;
  final data = message.data;
  final pondIdStr = data['pond_id'] ?? data['kolam_id'];
  final mqttId = data['mqtt_id'] ?? data['device_code'];
  
  final context = navigatorKey.currentContext;
  if (context != null) {
    final kolamBloc = context.read<KolamBloc>();
    
    void navigate(List<KolamEntity> list) {
      KolamEntity? matched;
      if (pondIdStr != null) {
        final pondId = int.tryParse(pondIdStr.toString());
        matched = list.firstWhere(
          (k) => k.id == pondId,
          orElse: () => null as dynamic,
        );
      }
      if (matched == null && mqttId != null) {
        matched = list.firstWhere(
          (k) => k.mqttId == mqttId.toString(),
          orElse: () => null as dynamic,
        );
      }
      if (matched != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => PondDetailScreen(kolam: matched!),
          ),
        );
      }
    }

    if (kolamBloc.state is KolamLoaded) {
      navigate((kolamBloc.state as KolamLoaded).kolams);
    } else {
      kolamBloc.add(FetchKolams());
      Future.delayed(const Duration(seconds: 1), () {
        if (kolamBloc.state is KolamLoaded) {
          navigate((kolamBloc.state as KolamLoaded).kolams);
        }
      });
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.subscribeToTopic('tambak_alerts');

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF131B2E), // Surface Low
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFF6CD3F7), size: 28), // Cyan icon
                const SizedBox(width: 8),
                const Text(
                  'BAHAYA SENSOR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6CD3F7), // Cyan text
                  ),
                ),
              ],
            ),
            content: Text(
              message.notification?.body ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFDAE2FD), // High contrast text
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6CD3F7),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationClick(message);
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleNotificationClick(message);
    }
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");
  globalApiClient = ApiClient(
    secureStorage: globalSecureStorage,
    onUnauthorized: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection Setup

    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: globalApiClient,
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      secureStorage: globalSecureStorage,
    );

    final kolamRemoteDataSource = KolamRemoteDataSourceImpl(
      apiClient: globalApiClient,
    );
    final kolamRepository = KolamRepositoryImpl(
      remoteDataSource: kolamRemoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: authRepository)
                ..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => KolamBloc(repository: kolamRepository)..add(FetchKolams()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tambak Udang',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            onSurface: AppColors.textPrimary,
            error: AppColors.error,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFDAE2FD)),
            bodyMedium: TextStyle(color: Color(0xFFDAE2FD)),
            titleMedium: TextStyle(color: Color(0xFFDAE2FD)),
            titleLarge: TextStyle(color: Color(0xFFDAE2FD)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          cardTheme: const CardThemeData(
            color: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: AppColors.border, width: 1),
            ),
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CD3F7),
              foregroundColor: const Color(0xFF0B1326),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

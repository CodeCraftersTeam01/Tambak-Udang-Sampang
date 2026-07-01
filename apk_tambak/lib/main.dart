import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'core/security/secure_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/datasources/kolam_remote_datasource.dart';
import 'data/repositories/kolam_repository_impl.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'presentation/bloc/kolam_bloc.dart';
import 'presentation/ui/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SecureStorage globalSecureStorage = SecureStorage();
late final ApiClient globalApiClient;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.notification?.title ?? 'Peringatan', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message.notification?.body ?? ''),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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

    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: globalApiClient);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      secureStorage: globalSecureStorage,
    );

    final kolamRemoteDataSource = KolamRemoteDataSourceImpl(apiClient: globalApiClient);
    final kolamRepository = KolamRepositoryImpl(remoteDataSource: kolamRemoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository)..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => KolamBloc(repository: kolamRepository),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tambak Udang',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'Roboto', // Default standard font
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

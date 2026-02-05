import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/controllers/theme_controller.dart';
import 'app/services/storage_service.dart';
import 'app/services/socket_service.dart';
import 'app/services/location_service.dart';
import 'app/services/notification_service.dart';
import 'app/data/providers/api_client.dart';
import 'app/data/repositories/job_repository.dart';
import 'app/modules/jobs/controllers/jobs_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  // Initialize GetStorage
  await GetStorage.init();
  debugPrint('✅ GetStorage initialized');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await initServices();
  debugPrint('✅ All services initialized');

  runApp(const SendItPilotApp());
}

/// Initialize all services
Future<void> initServices() async {
  // Storage Service (must be first)
  await Get.putAsync(() => StorageService().init());
  debugPrint('✅ StorageService ready');
  
  // API Client
  Get.put(ApiClient());
  debugPrint('✅ ApiClient ready');
  
  // Theme Controller
  Get.put(ThemeController());
  debugPrint('✅ ThemeController ready');
  
  // Socket Service (for real-time communication)
  try {
    await Get.putAsync(() => SocketService().init());
    debugPrint('✅ SocketService ready');
  } catch (e) {
    debugPrint('⚠️ SocketService error: $e');
  }
  
  // Location Service (for GPS tracking) - don't block on permission
  try {
    Get.put(LocationService());
    debugPrint('✅ LocationService ready');
  } catch (e) {
    debugPrint('⚠️ LocationService error: $e');
  }
  
  // Job Repository
  Get.lazyPut<JobRepository>(() => JobRepository());
  debugPrint('✅ JobRepository ready');
  
  // Jobs Controller (global job state - permanent)
  Get.put(JobsController(), permanent: true);
  debugPrint('✅ JobsController ready');

  // NotificationService for push notifications
  Get.put(NotificationService());
  debugPrint('✅ NotificationService ready');
}

class SendItPilotApp extends StatelessWidget {
  const SendItPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'SendIt Pilot',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode.value,
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}

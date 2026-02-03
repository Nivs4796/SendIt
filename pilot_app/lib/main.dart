import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/controllers/theme_controller.dart';
import 'app/services/storage_service.dart';
import 'app/services/socket_service.dart';
import 'app/services/location_service.dart';
import 'app/data/providers/api_client.dart';
import 'app/data/repositories/job_repository.dart';
import 'app/modules/jobs/controllers/jobs_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await initServices();

  runApp(const SendItPilotApp());
}

/// Initialize all services
Future<void> initServices() async {
  // Storage Service (must be first)
  await Get.putAsync(() => StorageService().init());
  
  // API Client
  Get.put(ApiClient());
  
  // Theme Controller
  Get.put(ThemeController());
  
  // Socket Service (for real-time communication)
  await Get.putAsync(() => SocketService().init());
  
  // Location Service (for GPS tracking)
  await Get.putAsync(() => LocationService().init());
  
  // Job Repository
  Get.lazyPut<JobRepository>(() => JobRepository());
  
  // Jobs Controller (global job state - permanent)
  Get.put(JobsController(), permanent: true);
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
          initialRoute: Routes.login,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}

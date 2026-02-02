import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/controllers/theme_controller.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage_service.dart';
import 'app/services/location_service.dart';
import 'app/services/socket_service.dart';
import 'app/services/maps_service.dart';
import 'app/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await initServices();

  runApp(const SendItApp());
}

Future<void> initServices() async {
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());

  // Initialize theme controller
  Get.put(ThemeController());

  // Phase 3 Services
  // LocationService needs async init for permissions
  await Get.putAsync(() => LocationService().init());

  // SocketService for real-time communication
  Get.put(SocketService());

  // MapsService for map-related operations
  Get.put(MapsService());

  // PaymentService for payment processing
  Get.put(PaymentService());
}

class SendItApp extends StatelessWidget {
  const SendItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      title: 'SendIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.to.themeMode.value,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    ));
  }
}

import 'package:get/get.dart';
import '../../../data/repositories/booking_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register BookingRepository if not already registered
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }

    Get.lazyPut<HomeController>(() => HomeController());
  }
}

import 'package:get/get.dart';

import '../../../data/repositories/job_repository.dart';
import '../controllers/jobs_controller.dart';

/// Binding for jobs module
class JobsBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<JobRepository>(() => JobRepository());
    
    // Controller - put permanent since it manages global job state
    Get.put<JobsController>(JobsController(), permanent: true);
  }
}

/// Route names for the Pilot app
abstract class Routes {
  Routes._();

  // Splash & Auth
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';

  // Registration (multi-step)
  static const registration = '/registration';
  static const registrationPersonal = '/registration/personal';
  static const registrationVehicle = '/registration/vehicle';
  static const registrationDocuments = '/registration/documents';
  static const registrationBank = '/registration/bank';
  static const verificationPending = '/verification-pending';

  // Main App
  static const home = '/home';
  static const dashboard = '/dashboard';

  // Jobs
  static const activeJob = '/job/active';
  static const history = '/history';
  static const jobDetails = '/job/:id';
  static const jobHistory = '/jobs/history';
  static const multipleJobs = '/jobs/multiple';

  // Earnings & Wallet
  static const earnings = '/earnings';
  static const wallet = '/wallet';
  static const addMoney = '/wallet/add';
  static const withdraw = '/wallet/withdraw';
  static const transactions = '/wallet/transactions';

  // Vehicles
  static const vehicles = '/vehicles';
  static const addVehicle = '/vehicles/add';
  static const vehicleDetails = '/vehicles/:id';

  // Profile
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const bankDetails = '/profile/bank';
  static const documents = '/profile/documents';
  static const settings = '/settings';

  // Notifications
  static const notifications = '/notifications';

  // Rewards & Referrals
  static const rewards = '/rewards';
  static const referrals = '/referrals';

  // Support
  static const help = '/help';
  static const support = '/support';
}

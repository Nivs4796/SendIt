import 'package:get_storage/get_storage.dart';

import '../models/pilot_model.dart';

/// Repository for handling pilot authentication
class AuthRepository {
  final GetStorage _storage = GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _pilotKey = 'current_pilot';
  static const String _isLoggedInKey = 'is_logged_in';

  // TODO: Replace with actual API client
  // final ApiClient _apiClient = Get.find<ApiClient>();

  /// Check if pilot is logged in
  Future<bool> isLoggedIn() async {
    return _storage.read<bool>(_isLoggedInKey) ?? false;
  }

  /// Get current pilot from storage
  Future<PilotModel?> getCurrentPilot() async {
    final pilotJson = _storage.read<Map<String, dynamic>>(_pilotKey);
    if (pilotJson != null) {
      return PilotModel.fromJson(pilotJson);
    }
    return null;
  }

  /// Save pilot to storage
  Future<void> savePilot(PilotModel pilot) async {
    await _storage.write(_pilotKey, pilot.toJson());
  }

  /// Get auth token
  String? get token => _storage.read<String>(_tokenKey);

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp({
    required String phone,
    required String countryCode,
    required String userType,
  }) async {
    // TODO: Implement actual API call
    // final response = await _apiClient.post('/auth/send-otp', data: {
    //   'phone': phone,
    //   'country_code': countryCode,
    //   'user_type': userType,
    // });

    // Simulated response for development
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'OTP sent successfully',
    };
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
    required String userType,
  }) async {
    // TODO: Implement actual API call
    // final response = await _apiClient.post('/auth/verify-otp', data: {
    //   'phone': phone,
    //   'country_code': countryCode,
    //   'otp': otp,
    //   'user_type': userType,
    // });

    // Simulated response for development
    await Future.delayed(const Duration(seconds: 1));

    // Simulate: OTP 123456 = existing user, any other = new user
    final isNewUser = otp != '123456';

    if (isNewUser) {
      return {
        'success': true,
        'is_new_user': true,
        'token': 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
      };
    }

    // Existing pilot
    final pilot = PilotModel(
      id: 'pilot_123',
      name: 'Test Pilot',
      phone: phone,
      email: 'pilot@example.com',
      status: PilotStatus.active,
      verificationStatus: VerificationStatus.approved,
      isOnline: false,
      rating: 4.5,
      totalRides: 150,
      createdAt: DateTime.now(),
    );

    await _storage.write(_tokenKey, 'dummy_token');
    await _storage.write(_isLoggedInKey, true);
    await savePilot(pilot);

    return {
      'success': true,
      'is_new_user': false,
      'token': 'dummy_token',
      'pilot': pilot.toJson(),
    };
  }

  /// Register new pilot
  Future<Map<String, dynamic>> registerPilot({
    required Map<String, dynamic> personalDetails,
    required Map<String, dynamic> vehicleDetails,
    required Map<String, dynamic> documents,
    required Map<String, dynamic> bankDetails,
  }) async {
    // TODO: Implement actual API call
    // final response = await _apiClient.post('/pilots/register', data: {
    //   ...personalDetails,
    //   'vehicle_details': vehicleDetails,
    //   'documents': documents,
    //   'bank_details': bankDetails,
    // });

    // Simulated response
    await Future.delayed(const Duration(seconds: 2));

    final pilot = PilotModel(
      id: 'pilot_${DateTime.now().millisecondsSinceEpoch}',
      name: personalDetails['name'] as String,
      phone: personalDetails['phone'] as String,
      email: personalDetails['email'] as String?,
      address: personalDetails['address'] as String?,
      city: personalDetails['city'] as String?,
      state: personalDetails['state'] as String?,
      pincode: personalDetails['pincode'] as String?,
      status: PilotStatus.pending,
      verificationStatus: VerificationStatus.pending,
      isOnline: false,
      createdAt: DateTime.now(),
    );

    await _storage.write(_isLoggedInKey, true);
    await savePilot(pilot);

    return {
      'success': true,
      'message': 'Registration submitted successfully',
      'pilot': pilot.toJson(),
    };
  }

  /// Check verification status
  Future<Map<String, dynamic>> checkVerificationStatus() async {
    // TODO: Implement actual API call
    final pilot = await getCurrentPilot();
    
    return {
      'success': true,
      'status': pilot?.verificationStatus.value ?? 'pending',
      'pilot': pilot?.toJson(),
    };
  }

  /// Logout
  Future<void> logout() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_pilotKey);
    await _storage.write(_isLoggedInKey, false);
  }
}

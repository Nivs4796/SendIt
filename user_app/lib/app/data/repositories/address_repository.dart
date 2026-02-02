import '../models/address_model.dart';
import '../models/api_response.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class AddressRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get all addresses for the current user
  /// GET /addresses
  Future<ApiResponse<List<AddressModel>>> getAddresses() async {
    final response = await _apiClient.get(ApiConstants.addresses);

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final addressesData = apiResponse.data!['addresses'] as List<dynamic>?;
      final addresses = addressesData
              ?.map((json) => AddressModel.fromJson(json))
              .toList() ??
          [];

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: addresses,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get addresses',
    );
  }

  /// Get a single address by ID
  /// GET /addresses/{id}
  Future<ApiResponse<AddressModel>> getAddress(String id) async {
    final response = await _apiClient.get('${ApiConstants.addresses}/$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final addressData = apiResponse.data!['address'] ?? apiResponse.data;
      final address = AddressModel.fromJson(addressData);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: address,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to get address',
    );
  }

  /// Create a new address
  /// POST /addresses
  Future<ApiResponse<AddressModel>> createAddress({
    required String label,
    required String address,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
    required double lat,
    required double lng,
    bool isDefault = false,
  }) async {
    final data = <String, dynamic>{
      'label': label,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };

    if (landmark != null && landmark.isNotEmpty) {
      data['landmark'] = landmark;
    }

    final response = await _apiClient.post(
      ApiConstants.addresses,
      data: data,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final addressData = apiResponse.data!['address'] ?? apiResponse.data;
      final createdAddress = AddressModel.fromJson(addressData);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: createdAddress,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to create address',
    );
  }

  /// Update an existing address
  /// PATCH /addresses/{id}
  Future<ApiResponse<AddressModel>> updateAddress({
    required String id,
    String? label,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? lat,
    double? lng,
    bool? isDefault,
  }) async {
    final data = <String, dynamic>{};

    if (label != null) data['label'] = label;
    if (address != null) data['address'] = address;
    if (landmark != null) data['landmark'] = landmark;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (pincode != null) data['pincode'] = pincode;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (isDefault != null) data['isDefault'] = isDefault;

    final response = await _apiClient.patch(
      '${ApiConstants.addresses}/$id',
      data: data,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final addressData = apiResponse.data!['address'] ?? apiResponse.data;
      final updatedAddress = AddressModel.fromJson(addressData);

      return ApiResponse(
        success: true,
        message: apiResponse.message,
        data: updatedAddress,
      );
    }

    return ApiResponse(
      success: false,
      message: apiResponse.message ?? 'Failed to update address',
    );
  }

  /// Delete an address
  /// DELETE /addresses/{id}
  Future<ApiResponse> deleteAddress(String id) async {
    final response = await _apiClient.delete('${ApiConstants.addresses}/$id');

    final apiResponse = ApiResponse.fromJson(response.data, null);

    return ApiResponse(
      success: apiResponse.success,
      message: apiResponse.message ?? (apiResponse.success ? 'Address deleted' : 'Failed to delete address'),
    );
  }

  /// Set an address as default
  /// Convenience method that calls updateAddress with isDefault: true
  Future<ApiResponse<AddressModel>> setDefaultAddress(String id) async {
    return updateAddress(id: id, isDefault: true);
  }
}

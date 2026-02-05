import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class SupportRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get FAQs
  /// GET /support/faqs
  Future<List<FaqCategory>> getFaqs() async {
    try {
      final response = await _api.get(ApiConstants.faqs);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> faqsList = data is List 
            ? data 
            : (data['categories'] ?? data['faqs'] ?? []);
        return faqsList.map((e) => FaqCategory.fromJson(e)).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load FAQs',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Return mock data for development when network fails
      return _getMockFaqs();
    } on TimeoutException {
      return _getMockFaqs();
    } catch (e) {
      // Fallback to mock data for development
      return _getMockFaqs();
    }
  }

  /// Search FAQs
  /// GET /support/faqs?search=XXX
  Future<List<FaqItem>> searchFaqs(String query) async {
    try {
      final response = await _api.get(
        ApiConstants.faqs,
        queryParameters: {'search': query},
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Handle different response formats
        if (data is List) {
          // If it returns categories, flatten all FAQs
          if (data.isNotEmpty && data.first is Map && data.first.containsKey('faqs')) {
            final List<FaqItem> results = [];
            for (final category in data) {
              final faqs = (category['faqs'] as List?) ?? [];
              results.addAll(faqs.map((e) => FaqItem.fromJson(e)));
            }
            return results;
          }
          // Direct list of FAQ items
          return data.map((e) => FaqItem.fromJson(e)).toList();
        } else if (data is Map) {
          final List<dynamic> faqs = data['faqs'] ?? data['results'] ?? [];
          return faqs.map((e) => FaqItem.fromJson(e)).toList();
        }
        
        return [];
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to search FAQs',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Fallback: search in mock data
      return _searchMockFaqs(query);
    } on TimeoutException {
      return _searchMockFaqs(query);
    } catch (e) {
      return _searchMockFaqs(query);
    }
  }

  /// Create support ticket
  /// POST /support/tickets
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String category,
    String? bookingId,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.supportTickets,
        data: {
          'subject': subject,
          'description': description,
          'category': category,
          if (bookingId != null) 'bookingId': bookingId,
        },
      );
      
      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data['success'] == true) {
        final data = response.data['data'];
        final ticketData = data['ticket'] ?? data;
        return SupportTicket.fromJson(ticketData);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to create ticket',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create ticket: $e');
    }
  }

  /// Get support contact info
  /// GET /support/contact
  Future<SupportContact> getContactInfo() async {
    try {
      final response = await _api.get(ApiConstants.supportContact);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return SupportContact.fromJson(response.data['data']);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load contact info',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      return _getMockContactInfo();
    } on TimeoutException {
      return _getMockContactInfo();
    } catch (e) {
      return _getMockContactInfo();
    }
  }

  List<FaqItem> _searchMockFaqs(String query) {
    final allFaqs = _getMockFaqs();
    final results = <FaqItem>[];
    final queryLower = query.toLowerCase();
    
    for (final category in allFaqs) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(queryLower) ||
            faq.answer.toLowerCase().contains(queryLower)) {
          results.add(faq);
        }
      }
    }
    
    return results;
  }

  List<FaqCategory> _getMockFaqs() {
    return [
      FaqCategory(
        id: '1',
        name: 'Getting Started',
        icon: '🚀',
        faqs: [
          FaqItem(
            id: '1',
            question: 'How do I start accepting deliveries?',
            answer:
                'To start accepting deliveries, go to the Home screen and toggle the "Online" switch. Make sure your location services are enabled and you have an active vehicle selected.',
          ),
          FaqItem(
            id: '2',
            question: 'What documents do I need to complete registration?',
            answer:
                'You need to upload: Driving License, Vehicle RC, Insurance, Aadhaar Card, PAN Card, and a profile photo. All documents must be valid and clearly visible.',
          ),
          FaqItem(
            id: '3',
            question: 'How long does document verification take?',
            answer:
                'Document verification typically takes 24-48 hours. You will receive a notification once your documents are verified. If rejected, you can re-upload with the correct documents.',
          ),
        ],
      ),
      FaqCategory(
        id: '2',
        name: 'Earnings & Payments',
        icon: '💰',
        faqs: [
          FaqItem(
            id: '4',
            question: 'How do I withdraw my earnings?',
            answer:
                'Go to Wallet > Withdraw. Select your bank account and enter the amount you wish to withdraw. Withdrawals are typically processed within 1-2 business days.',
          ),
          FaqItem(
            id: '5',
            question: 'What are the withdrawal limits?',
            answer:
                'Minimum withdrawal: ₹100. Maximum withdrawal: ₹50,000 per transaction. You can make up to 3 withdrawals per day.',
          ),
          FaqItem(
            id: '6',
            question: 'How are delivery earnings calculated?',
            answer:
                'Earnings = Base Fare + Distance Fare + Time Fare + Surge (if applicable). You receive 80% of the delivery fare. Tips are 100% yours.',
          ),
          FaqItem(
            id: '7',
            question: 'When do I receive bonuses?',
            answer:
                'Bonuses are awarded for completing daily/weekly targets, peak hour deliveries, consecutive trips, and special promotions. Check the Rewards section for current offers.',
          ),
        ],
      ),
      FaqCategory(
        id: '3',
        name: 'Deliveries',
        icon: '📦',
        faqs: [
          FaqItem(
            id: '8',
            question: 'What happens if a customer is not available?',
            answer:
                'Wait for 5 minutes and try calling the customer. If unreachable, mark "Customer Unavailable" in the app. Follow the on-screen instructions for further steps.',
          ),
          FaqItem(
            id: '9',
            question: 'Can I cancel a delivery after accepting?',
            answer:
                'You can cancel only before pickup. Frequent cancellations may affect your acceptance rate and eligibility for bonuses. Valid reasons include vehicle breakdown or emergency.',
          ),
          FaqItem(
            id: '10',
            question: 'What items cannot be delivered?',
            answer:
                'Prohibited items include: illegal substances, weapons, flammable materials, live animals, and items exceeding weight/size limits. Report any suspicious packages.',
          ),
        ],
      ),
      FaqCategory(
        id: '4',
        name: 'Account & Profile',
        icon: '👤',
        faqs: [
          FaqItem(
            id: '11',
            question: 'How do I update my phone number?',
            answer:
                'Contact support to update your registered phone number. You will need to verify your identity and provide the new number for OTP verification.',
          ),
          FaqItem(
            id: '12',
            question: 'How do I add a new vehicle?',
            answer:
                'Go to Profile > My Vehicles > Add Vehicle. Enter the vehicle details and upload the RC document. The vehicle will be verified within 24-48 hours.',
          ),
          FaqItem(
            id: '13',
            question: 'What happens if my documents expire?',
            answer:
                'You will receive notifications before expiry. Expired documents will prevent you from going online. Upload renewed documents through Documents section.',
          ),
        ],
      ),
      FaqCategory(
        id: '5',
        name: 'Safety & Emergency',
        icon: '🛡️',
        faqs: [
          FaqItem(
            id: '14',
            question: 'What should I do in case of an accident?',
            answer:
                'Ensure your safety first. Call emergency services if needed. Use the SOS button in the app to alert our support team. Document the incident with photos.',
          ),
          FaqItem(
            id: '15',
            question: 'How do I report a safety issue?',
            answer:
                'Use Help & Support > Report Issue > Safety Concern. Our safety team will contact you within 24 hours. For emergencies, use the SOS button.',
          ),
        ],
      ),
    ];
  }

  SupportContact _getMockContactInfo() {
    return SupportContact(
      phone: '+91 1800-123-4567',
      email: 'pilot-support@sendit.com',
      whatsapp: '+91 9876543210',
      workingHours: '24/7 Support Available',
    );
  }
}

/// FAQ Category
class FaqCategory {
  final String id;
  final String name;
  final String icon;
  final List<FaqItem> faqs;

  FaqCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.faqs,
  });

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? json['title'] ?? json['category'] ?? '',
      icon: json['icon'] ?? json['emoji'] ?? '❓',
      faqs: ((json['faqs'] ?? json['questions'] ?? json['items']) as List?)
              ?.map((e) => FaqItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// FAQ Item
class FaqItem {
  final String id;
  final String question;
  final String answer;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      question: json['question'] ?? json['q'] ?? '',
      answer: json['answer'] ?? json['a'] ?? '',
    );
  }
}

/// Support Ticket
class SupportTicket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String status;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      ticketNumber: json['ticketNumber'] ?? json['number'] ?? json['id'] ?? '',
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Support Contact
class SupportContact {
  final String phone;
  final String email;
  final String? whatsapp;
  final String workingHours;

  SupportContact({
    required this.phone,
    required this.email,
    this.whatsapp,
    required this.workingHours,
  });

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      whatsapp: json['whatsapp'] ?? json['whatsappNumber'],
      workingHours: json['workingHours'] ?? json['hours'] ?? '',
    );
  }
}

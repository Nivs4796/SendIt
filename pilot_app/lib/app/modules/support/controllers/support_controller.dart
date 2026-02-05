import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/support_repository.dart';

class SupportController extends GetxController {
  final SupportRepository _repository = SupportRepository();

  // State
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final faqCategories = <FaqCategory>[].obs;
  final contact = Rxn<SupportContact>();
  
  // Search
  final searchQuery = ''.obs;
  final searchResults = <FaqItem>[].obs;

  // Expanded FAQ
  final expandedFaqId = ''.obs;

  // Ticket form
  final ticketFormKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedCategory = 'general'.obs;

  final ticketCategories = [
    {'key': 'general', 'label': 'General Query'},
    {'key': 'payment', 'label': 'Payment Issue'},
    {'key': 'delivery', 'label': 'Delivery Problem'},
    {'key': 'document', 'label': 'Document Verification'},
    {'key': 'technical', 'label': 'Technical Issue'},
    {'key': 'safety', 'label': 'Safety Concern'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Load FAQs and contact info
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.getFaqs(),
        _repository.getContactInfo(),
      ]);
      faqCategories.value = results[0] as List<FaqCategory>;
      contact.value = results[1] as SupportContact;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load support data',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Search FAQs
  void searchFaqs(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final results = <FaqItem>[];
    final queryLower = query.toLowerCase();
    
    for (final category in faqCategories) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(queryLower) ||
            faq.answer.toLowerCase().contains(queryLower)) {
          results.add(faq);
        }
      }
    }
    
    searchResults.value = results;
  }

  /// Toggle FAQ expansion
  void toggleFaq(String faqId) {
    if (expandedFaqId.value == faqId) {
      expandedFaqId.value = '';
    } else {
      expandedFaqId.value = faqId;
    }
  }

  /// Submit support ticket
  Future<void> submitTicket() async {
    if (!ticketFormKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;
      final ticket = await _repository.createTicket(
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
      );

      // Clear form
      subjectController.clear();
      descriptionController.clear();
      selectedCategory.value = 'general';

      Get.back();
      Get.snackbar(
        'Ticket Created',
        'Your ticket #${ticket.ticketNumber} has been submitted. We\'ll get back to you soon.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Call support
  Future<void> callSupport() async {
    final phone = contact.value?.phone;
    if (phone == null) return;
    
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not make phone call',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  /// Email support
  Future<void> emailSupport() async {
    final email = contact.value?.email;
    if (email == null) return;
    
    final url = Uri.parse('mailto:$email?subject=Pilot Support Request');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not open email app',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  /// WhatsApp support
  Future<void> whatsappSupport() async {
    final whatsapp = contact.value?.whatsapp;
    if (whatsapp == null) return;
    
    final number = whatsapp.replaceAll('+', '').replaceAll(' ', '');
    final url = Uri.parse('https://wa.me/$number?text=Hi, I need help with...');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  /// Refresh data
  Future<void> refresh() => loadData();
}

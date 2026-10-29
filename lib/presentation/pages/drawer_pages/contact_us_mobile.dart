import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_success_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/content_provider.dart';
import '../../../services/logging_service.dart';

bool validateEmail(String email) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  String? _formError;
  bool isSubmitting = false;

  final List<PlatformFile> _selectedImages = [];

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only add up to 2 images.")),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!mounted) return;
        if (!_selectedImages.any((x) => x.path == file.path)) {
          setState(() => _selectedImages.add(file));
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("contact_us_mobile");
    LoggingService().setCrashlyticsScreen("contact_us_mobile");
    final authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = authenticationProvider.getUser();
    if (user != null) {
      nameController.text = user.username ?? "";
      phoneController.text = user.contactNumber ?? "";
      emailController.text = user.email ?? "";
    }
  }

  Future<void> _submit() async {
    if (isSubmitting) return;
    String? error;
    if (nameController.text.isEmpty) {
      error = "Please enter your name";
    } else if (nameController.text.length > 100) {
      error = "Name can be at most 100 characters";
    } else if (phoneController.text.isEmpty) {
      error = "Please enter your phone number";
    } else if (phoneController.text.length > 15 || phoneController.text.length < 10) {
      error = "Enter a valid phone number";
    } else if (emailController.text.isNotEmpty && !validateEmail(emailController.text)) {
      error = "Please enter a valid email";
    } else if (emailController.text.length > 100) {
      error = "Email can be at most 100 characters";
    } else if (subjectController.text.isEmpty) {
      error = "Please enter a subject";
    } else if (subjectController.text.length > 200) {
      error = "Subject can be at most 200 characters";
    } else if (messageController.text.isEmpty) {
      error = "Please enter a message";
    } else if (messageController.text.length > 1000) {
      error = "Message can be at most 1,000 characters";
    }

    if (error != null) {
      setState(() => _formError = error);
      return;
    }

    setState(() {
      _formError = null;
      isSubmitting = true;
    });

    final Map<String, dynamic> requestData = {
      "name": nameController.text,
      "phone_number": phoneController.text,
      "subject": subjectController.text,
      "message": messageController.text,
    };
    if (emailController.text.isNotEmpty) {
      requestData["email"] = emailController.text;
    }

    NetworkService().post(
      APIPath.contactUs,
      requestData,
      (data) {
        if (!mounted) return;
        setState(() => isSubmitting = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsSuccessPage()),
        );
      },
      (error) {
        if (!mounted) return;
        setState(() => isSubmitting = false);
      },
      () {},
      files: _selectedImages.map((f) => File(f.path!)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep this tree stable when the keyboard opens. Swapping between a
            // plain box and a scroll view recreates the fields and drops focus.
            const minHeight = 560.0;
            final formHeight = constraints.maxHeight < minHeight ? minHeight : constraints.maxHeight;
            return SingleChildScrollView(
              child: SizedBox(
                height: formHeight,
                child: _form(contentProvider),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _form(ContentProvider contentProvider) {
    final phone = contentProvider.getSupportPhoneNumber();
    final email = contentProvider.getSupportEmail();
    final timing = contentProvider.getSupportTiming();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                gradient: AppColors.brandTextGradient,
              ),
              padding: const EdgeInsets.all(1.4),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22.6)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF173044), Color(0xFF0B1018), Color(0xFF161208)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/cineprime-icon.png', height: 40),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CINEPRIME',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.colorPrimaryLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'How can we help?',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _field(nameController, 'Name', Icons.person_outline_rounded)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _field(
                            phoneController,
                            'Phone',
                            Icons.phone_outlined,
                            type: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            emailController,
                            'Email',
                            Icons.mail_outline_rounded,
                            type: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _field(subjectController, 'Subject', Icons.subject_rounded)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _messageField(),
                    ),
                    SizedBox(
                      height: 16,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formError ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.7)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.colorPrimary, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Screenshot',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      color: AppColors.colorPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final file = _selectedImages[index];
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path!),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedImages.remove(file)),
                                        child: const CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Color(0xFF1A1406),
                                          child: Icon(Icons.close, size: 10, color: AppColors.colorPrimary),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GradientButton(
                      label: 'Send message',
                      height: 46,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                    if (phone.isNotEmpty || email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (phone.isNotEmpty)
                            _contactLink(
                              icon: Icons.call_rounded,
                              label: timing.isNotEmpty ? '$phone · $timing' : phone,
                              onTap: () async {
                                final url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              },
                            ),
                          if (phone.isNotEmpty && email.isNotEmpty) const SizedBox(width: 14),
                          if (email.isNotEmpty)
                            _contactLink(
                              icon: Icons.mail_rounded,
                              label: email,
                              onTap: () async {
                                final emailUri = Uri(scheme: 'mailto', path: email);
                                if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.colorPrimaryLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.colorPrimaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageField() {
    return Stack(
      fit: StackFit.expand,
      children: [
        TextField(
          controller: messageController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: null,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: AppColors.colorPrimary,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF0C121C),
            hintText: 'Message',
            hintStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppColors.colorHint,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: const EdgeInsets.fromLTRB(40, 12, 12, 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.colorInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.colorPrimary),
            ),
          ),
        ),
        const Positioned(
          left: 12,
          top: 14,
          child: IgnorePointer(
            child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.colorPrimaryLight),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      minLines: 1,
      maxLines: 1,
      cursorColor: AppColors.colorPrimary,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF0C121C),
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AppColors.colorHint,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppColors.colorPrimaryLight),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.colorInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}

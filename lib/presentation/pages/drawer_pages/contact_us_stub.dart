import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:cineprime/presentation/components/controls/buttons.dart';
import 'package:cineprime/presentation/components/controls/text_input.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_success_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/content_provider.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  String? titleError;
  String? messageError;
  String? selectedItemError;
  String? selectedItem;
  final _issueTypes = [
    "Payment/Subscription Issue",
    "Account Issue",
    "Streaming Issue",
    "Any Other"
  ];

  @override
  Widget build(BuildContext context) {
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextInput(
                  controller: titleController,
                  hintText: "Subject",
                  obscureText: false,
                  isLast: false,
                  errorText: titleError,
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: DropdownButtonFormField<String>(
                      hint: Text(
                        "Type Of Issue",
                        style: TextStyle(color: AppColors.colorHint),
                      ),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: AppColors.colorPrimaryLight,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            color: AppColors.colorPrimaryLight,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0x45454545),
                        label: const Text(
                          "Issue Type",
                          style: TextStyle(color: AppColors.colorPrimaryLight),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        errorText: selectedItemError,
                      ),
                      style:
                          const TextStyle(color: AppColors.colorPrimaryLight),
                      dropdownColor: AppColors.colorHint,
                      value: selectedItem,
                      items: _issueTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          enabled: true,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        setState(() {
                          selectedItem = selected!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextInput(
                  controller: messageController,
                  hintText: "Message",
                  obscureText: false,
                  minLines: 5,
                  isLast: true,
                  errorText: messageError,
                ),
                const SizedBox(height: 20),
                SubmitButton(
                  buttonText: "Submit Message",
                  onPressed: () async {
                    titleError = null;
                    selectedItemError = null;
                    messageError = null;
                    if (titleController.text.isEmpty) {
                      setState(() {
                        titleError = "";
                      });
                      return;
                    }
                    if (selectedItem == null) {
                      setState(() {
                        selectedItemError = "";
                      });
                      return;
                    }
                    if (messageController.text.isEmpty) {
                      setState(() {
                        messageError = "";
                      });
                      return;
                    }
                    if (titleController.text.length > 200) {
                      setState(() {
                        titleError = "Max Length: 200 Characters";
                      });
                      return;
                    }
                    if (messageController.text.length > 1000) {
                      setState(() {
                        messageError = "Max Length: 1,000 Characters";
                      });
                      return;
                    }
                    NetworkService().post(APIPath.contactUs, {
                      "title": titleController.text,
                      "type": selectedItem,
                      "message": messageController.text
                    }, (data) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsSuccessPage(),
                        ),
                      );
                    }, (error) {}, () {});
                  },
                ),
                const SizedBox(height: 25),
                if (contentProvider.getSupportPhoneNumber().isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(
                          "tel:${contentProvider.getSupportPhoneNumber()}");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      contentProvider.getSupportPhoneNumber(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.colorPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                if (contentProvider.getSupportEmail().isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: contentProvider.getSupportEmail(),
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                    child: Text(
                      contentProvider.getSupportEmail(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.colorPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

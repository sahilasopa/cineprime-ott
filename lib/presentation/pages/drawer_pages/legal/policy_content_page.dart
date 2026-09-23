import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';

class PolicyContentPage extends StatefulWidget {
  final String title;
  final Future<String?> Function() getContent;

  const PolicyContentPage({
    super.key,
    required this.title,
    required this.getContent,
  });

  @override
  State<PolicyContentPage> createState() => _PolicyContentPageState();
}

class _PolicyContentPageState extends State<PolicyContentPage> {
  String? _content;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final content = await widget.getContent();
      if (mounted) {
        setState(() {
          _content = content ?? 'Content not available. Please check your internet connection and try again.';
          _isLoading = false;
          _hasError = content == null || content.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _content = 'Failed to load content. Please try again.';
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.colorPrimary,
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.colorPrimary,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _content ?? 'Failed to load content',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                          ElevatedButton(
                          onPressed: _loadContent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _content ?? 'No content available',
                      style: const TextStyle(
                        color: AppColors.colorTextSecondary,
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
      ),
    );
  }
}


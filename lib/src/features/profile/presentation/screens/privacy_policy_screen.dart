import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Privacy Policy",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.teal.withValues(alpha: 0.1),
                      const Color(0xFFF5F7F9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _controller,
                    child: Center(
                      child: Text(
                        "Last Updated: January 30, 2026",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedSection(
                    0,
                    "1. Introduction",
                    "Med Shakthi ('we', 'our', or 'us') is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by Med Shakthi. This Privacy Policy applies to our mobile application and its associated subdomains. By using our Service, you agree to our collection and use of your personal information as described here.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    1,
                    "2. Information We Collect",
                    "We collect information to provide better services. Specifically:\n\n"
                        "• Personal Information: Name, email, phone, and delivery address.\n"
                        "• Health Information: Prescriptions and health data you voluntarily provide.\n"
                        "• Usage Data: Features accessed and time spent.\n"
                        "• Device Information: Device type, OS version, and IP address.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    2,
                    "3. How We Use Your Data",
                    "We use the collected information to:\n\n"
                        "• Provide and operate our Service.\n"
                        "• Process orders and manage accounts.\n"
                        "• Personalize user experience.\n"
                        "• Communicate updates and support.\n"
                        "• Detect and prevent fraud.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    3,
                    "4. Data Security",
                    "We apply robust security measures (administrative, technical, and physical) to protect your data. While we strive for maximum security, no method of transmission over the internet is 100% secure.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    4,
                    "5. Third-Party Services",
                    "We may employ third-party companies for:\n\n"
                        "• Service facilitation\n"
                        "• Analytics\n"
                        "• Payment processing\n\n"
                        "These parties have access to your personal data only to perform specific tasks on our behalf and are obligated not to disclose it.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    5,
                    "6. Your Rights",
                    "You have the right to access, update, or delete your information. You can manage your data directly within the app settings. Contact us if you need assistance.",
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    6,
                    "7. Contact Us",
                    "For any questions regarding this Privacy Policy:\n\n"
                        "• Email: support@medshakthi.com\n"
                        "• Website: www.medshakthi.com/contact",
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, String title, String content) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3B48),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

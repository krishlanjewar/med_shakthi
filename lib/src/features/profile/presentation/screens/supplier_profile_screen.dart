import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';

class SupplierProfileScreen extends StatefulWidget {
  const SupplierProfileScreen({super.key});

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isEditing = false; // Track editing state

  // Controllers for editable fields
  final _companyNameController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _drugLicenseController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();

  // Read-only / Status fields
  String _email = '';
  String _status = 'Verified';
  String _supplierCode = '';
  String _drugLicenseExpiry = ''; // Usually date picker, keeping simple for now
  String _companyType = '';

  @override
  void initState() {
    super.initState();
    _fetchSupplierData();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _supplierNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _drugLicenseController.dispose();
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _fetchSupplierData() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '';
      });

      try {
        final data = await supabase
            .from('suppliers')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null) {
          setState(() {
            _companyNameController.text = data['company_name'] ?? '';
            _supplierNameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _status = data['verification_status'] ?? 'Pending';
            _supplierCode = data['supplier_code'] ?? '';

            // Address
            _addressController.text = data['company_address'] ?? '';
            _cityController.text = data['city'] ?? '';
            _stateController.text = data['state'] ?? '';
            _pincodeController.text = data['pincode'] ?? '';
            _countryController.text = data['country'] ?? '';

            // Legal
            _drugLicenseController.text = data['drug_license_number'] ?? '';
            _drugLicenseExpiry = data['drug_license_expiry'] ?? '';
            _gstController.text = data['gst_number'] ?? '';
            _panController.text = data['pan_number'] ?? '';
            _companyType = data['company_type'] ?? '';
          });
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('suppliers')
          .update({
            'company_name': _companyNameController.text,
            'name': _supplierNameController.text,
            'phone': _phoneController.text,
            'company_address': _addressController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'pincode': _pincodeController.text,
            'country': _countryController.text,
            'drug_license_number': _drugLicenseController.text,
            'gst_number': _gstController.text,
            'pan_number': _panController.text,
          })
          .eq('user_id', user.id);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            color: const Color(0xFF4C8077),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Header Profile Card (Existing UI)
                  _buildProfileHeader(),
                  const SizedBox(height: 20),

                  // 2. Business Details Section
                  _buildExpansionSection(
                    title: "Business Details",
                    icon: Icons.business,
                    children: [
                      _buildInfoRow(
                        Icons.business_center,
                        "Type",
                        _companyType,
                        isEditable: false,
                      ),
                      _buildInfoRow(
                        Icons.person,
                        "Owner",
                        _supplierNameController.text,
                        controller: _supplierNameController,
                      ),
                      _buildInfoRow(
                        Icons.phone,
                        "Phone",
                        _phoneController.text,
                        controller: _phoneController,
                      ),
                      _buildInfoRow(
                        Icons.email,
                        "Email",
                        _email,
                        isEditable: false,
                      ), // Email usually not editable directly
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Address Section
                  _buildExpansionSection(
                    title: "Address",
                    icon: Icons.location_on,
                    children: [
                      _buildInfoRow(
                        Icons.location_city,
                        "City",
                        _cityController.text,
                        controller: _cityController,
                      ),
                      _buildInfoRow(
                        Icons.map,
                        "State",
                        _stateController.text,
                        controller: _stateController,
                      ),
                      _buildInfoRow(
                        Icons.pin_drop,
                        "Pincode",
                        _pincodeController.text,
                        controller: _pincodeController,
                      ),
                      _buildInfoRow(
                        Icons.public,
                        "Country",
                        _countryController.text,
                        controller: _countryController,
                      ),
                      _buildInfoRow(
                        Icons.home,
                        "Full Address",
                        _addressController.text,
                        controller: _addressController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Legal & Tax Section
                  _buildExpansionSection(
                    title: "Legal & Licenses",
                    icon: Icons.verified_user,
                    children: [
                      _buildInfoRow(
                        Icons.assignment,
                        "Drug License",
                        _drugLicenseController.text,
                        controller: _drugLicenseController,
                      ),
                      _buildInfoRow(
                        Icons.calendar_today,
                        "License Expiry",
                        _drugLicenseExpiry,
                        isEditable: false,
                      ),
                      _buildInfoRow(
                        Icons.receipt_long,
                        "GST Number",
                        _gstController.text,
                        controller: _gstController,
                      ),
                      _buildInfoRow(
                        Icons.badge,
                        "PAN Number",
                        _panController.text,
                        controller: _panController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Account Actions
                  _buildSectionTitle("Settings"),
                  _buildMenuOption(Icons.settings, "Account Settings", () {}),
                  _buildMenuOption(Icons.notifications, "Notifications", () {}),
                  _buildMenuOption(Icons.help, "Help & Support", () {}),
                  _buildMenuOption(Icons.logout, "Logout", _handleLogout),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF4C8077).withValues(alpha: 0.1),
                child: Text(
                  _companyNameController.text.isNotEmpty
                      ? _companyNameController.text[0].toUpperCase()
                      : "S",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C8077),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Editable Company Name if in editing mode
          _isEditing
              ? TextField(
                  controller: _companyNameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Company Name",
                    border: UnderlineInputBorder(),
                  ),
                )
              : Text(
                  _companyNameController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 4),
          Text(_email, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _status == 'APPROVED' || _status == 'Verified'
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Status: $_status",
              style: TextStyle(
                color: _status == 'APPROVED' || _status == 'Verified'
                    ? Colors.green
                    : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_supplierCode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Code: $_supplierCode",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4C8077).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4C8077), size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          children: children,
        ),
      ),
    );
  }

  // Modified helper to support editing
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    TextEditingController? controller,
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isEditing && isEditable && controller != null)
                  SizedBox(
                    height: 30, // constrain height for edit field in row
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  )
                else
                  Text(
                    value.isNotEmpty ? value : "Not Provided",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4C8077).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4C8077), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}

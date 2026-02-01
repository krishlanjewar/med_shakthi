import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:med_shakthi/src/core/api/supabase_service.dart';
import 'package:med_shakthi/src/core/utils/indian_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Assuming SupplierDashboard is located here based on your project structure
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';

class SupplierSignupPage extends StatefulWidget {
  const SupplierSignupPage({super.key});

  @override
  State<SupplierSignupPage> createState() => _SupplierSignupPageState();
}

class _SupplierSignupPageState extends State<SupplierSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final SupabaseClient supabase = Supabase.instance.client;
  static const String _countryCode = '+91';

  bool _isFormValid = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _selectedState;
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _drugLicenseNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCompanyType;
  DateTime? _selectedExpiryDate;
  File? _selectedDocument;
  String? _documentPath;

  final List<String> _companyTypes = [
    'PROPRIETORSHIP',
    'LLP',
    'PVT_LTD',
    'PARTNERSHIP',
  ];

  @override
  void initState() {
    super.initState();
    _registerListeners();
  }

  void _registerListeners() {
    _nameController.addListener(_checkValidity);
    _emailController.addListener(_checkValidity);
    _phoneController.addListener(_checkValidity);
    _countryController.addListener(_checkValidity);

    // State handled by onChanged
    _cityController.addListener(_checkValidity);
    _pincodeController.addListener(_checkValidity);
    _companyNameController.addListener(_checkValidity);
    _companyAddressController.addListener(_checkValidity);
    _drugLicenseNumberController.addListener(_checkValidity);
    _gstNumberController.addListener(_checkValidity);
    _panNumberController.addListener(_checkValidity);
    _passwordController.addListener(_checkValidity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();

    // _stateController removed
    _cityController.dispose();
    _pincodeController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _drugLicenseNumberController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _checkValidity();
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentPath = result.files.single.name;
        _checkValidity();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // ... (Validation checks remain the same) ...
    if (_selectedCompanyType == null) {
      _showError('Please select company type');
      return;
    }
    if (_selectedExpiryDate == null) {
      _showError('Please select drug license expiry date');
      return;
    }
    if (_selectedDocument == null) {
      _showError('Please upload drug license document');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String phone = '$_countryCode${_phoneController.text.trim()}';

      // 🔐 STEP 1: AUTH SIGNUP
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'phone': phone,
          'role': 'supplier',
        },
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Auth signup failed');
      final userId = user.id;

      // 📂 STEP 2: UPLOAD DOCUMENT
      final fileName =
          'drug_license_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final documentUrl = await SupabaseService.uploadDocument(
        bucket: 'drug-licenses',
        file: _selectedDocument!,
        fileName: fileName,
      );

      // 🧾 STEP 3: INSERT INTO SUPPLIERS TABLE
      // Use upsert to handle potential conflicts
      await supabase.from('suppliers').upsert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),

        // ✅ ADDED THIS BACK to satisfy the "NOT NULL" database constraint
        'password': _passwordController.text.trim(),

        'phone': phone,
        'country': _countryController.text.trim(),
        'state': _selectedState,
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'company_name': _companyNameController.text.trim(),
        'company_type': _selectedCompanyType,
        'company_address': _companyAddressController.text.trim(),
        'drug_license_number': _drugLicenseNumberController.text.trim(),
        'drug_license_expiry': _selectedExpiryDate!.toIso8601String(),
        'drug_license_document': documentUrl,
        'gst_number': _gstNumberController.text.trim(),
        'pan_number': _panNumberController.text.trim(),
        'verification_status': 'PENDING',
      }, onConflict: 'user_id');

      // ✅ SUCCESS UI & NAVIGATION
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Submitted! Welcome.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Supplier Dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SupplierDashboard()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4F2), Color(0xFFF6FBFA)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF6AA39B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Supplier Registration',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Join our network and grow your business',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 30),

                        _sectionTitle('Basic Info'),
                        _buildTextField(
                          _nameController,
                          'Contact Person Name',
                          Icons.person,
                        ),
                        _buildTextField(
                          _emailController,
                          'Email Address',
                          Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value != null && value.contains('@')
                              ? null
                              : 'Enter valid email',
                        ),
                        _buildTextField(
                          _phoneController,
                          'Phone Number',
                          Icons.phone,
                          prefixText: '$_countryCode ',
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: IndianValidators.validateMobile,
                        ),
                        _buildTextField(
                          _passwordController,
                          'Password',
                          Icons.lock,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) =>
                              value != null && value.length >= 6
                              ? null
                              : 'Min 6 characters',
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Location'),
                        _buildTextField(
                          _countryController,
                          'Country',
                          Icons.public,
                          readOnly: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            value: _selectedState,
                            menuMaxHeight: 300, // UX Fix: Limit height
                            isExpanded: true, // UX Fix: Prevent overflow
                            decoration: InputDecoration(
                              labelText: 'State',
                              prefixIcon: const Icon(Icons.map, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: IndianValidators.indianStates.map((state) {
                              return DropdownMenuItem(
                                value: state,
                                child: Text(
                                  state,
                                  overflow: TextOverflow
                                      .ellipsis, // UX Fix: Truncate text
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedState = value);
                              _checkValidity();
                            },
                            validator: (value) =>
                                value == null ? 'Select State' : null,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _cityController,
                                'City',
                                Icons.location_city,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]'),
                                  ),
                                ],
                                validator: IndianValidators.validateCity,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildTextField(
                                _pincodeController,
                                'Pincode',
                                Icons.pin_drop,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: IndianValidators.validatePincode,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Business Details'),
                        _buildTextField(
                          _companyNameController,
                          'Company Name',
                          Icons.business,
                        ),
                        _buildDropdown(),
                        _buildTextField(
                          _companyAddressController,
                          'Full Business Address',
                          Icons.home_work,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Legal & Documents'),
                        _buildTextField(
                          _drugLicenseNumberController,
                          'Drug License Number',
                          Icons.description,
                        ),
                        _buildDatePicker(),
                        const SizedBox(height: 10),
                        _buildFilePicker(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _gstNumberController,
                          'GST Number',
                          Icons.receipt_long,
                          textCapitalization: TextCapitalization.characters,
                          maxLength:
                              15, // PROMPT: Restrict GSTIN Input (Max 15 chars)
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]'),
                            ), // Strict alphanumeric
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          // validator: IndianValidators.validateGSTIN, // Commented for testing
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter GST Number'
                              : null,
                        ),
                        _buildTextField(
                          _panNumberController,
                          'PAN Number',
                          Icons.credit_card,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 10,
                          inputFormatters: [UpperCaseTextFormatter()],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          // validator: IndianValidators.validatePAN, // Commented for testing
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter PAN Number'
                              : null,
                        ),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: _isFormValid
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF6AA39B,
                                        ).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: _isFormValid ? _submitForm : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFormValid
                                    ? const Color(0xFF6AA39B)
                                    : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Submit for Verification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6AA39B),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        autovalidateMode:
            autovalidateMode ??
            AutovalidateMode
                .onUserInteraction, // PROMPT: Enable Real-time Error Highlights (All Fields)
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          prefixText: prefixText,
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator:
            validator ??
            (value) => value == null || value.isEmpty
                ? 'This field is required'
                : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCompanyType,
        isExpanded: true, // UX Fix: Prevent overflow
        menuMaxHeight: 300, // UX Fix: Limit height
        decoration: InputDecoration(
          labelText: 'Company Type',
          prefixIcon: const Icon(Icons.category, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        items: _companyTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type, overflow: TextOverflow.ellipsis, maxLines: 1),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCompanyType = value);
          _checkValidity();
        },
        validator: (value) =>
            value == null ? 'Please select company type' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              _selectedExpiryDate == null
                  ? 'Drug License Expiry Date'
                  : 'Expiry: ${DateFormat('dd MMM yyyy').format(_selectedExpiryDate!)}',
              style: TextStyle(
                color: _selectedExpiryDate == null
                    ? Colors.grey[700]
                    : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6AA39B).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6AA39B).withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: const Color(0xFF6AA39B),
            ),
            const SizedBox(height: 10),
            Text(
              _documentPath ?? 'Upload Drug License Document',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6AA39B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '(PDF, JPG, PNG up to 5MB)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _checkValidity() {
    final isValid =
        _nameController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _phoneController.text.length == 10 &&
        _passwordController.text.length >= 6 &&
        _countryController.text.isNotEmpty &&
        _selectedState != null &&
        _cityController.text.isNotEmpty &&
        _pincodeController.text.isNotEmpty &&
        _companyNameController.text.isNotEmpty &&
        _selectedCompanyType != null &&
        _companyAddressController.text.isNotEmpty &&
        _drugLicenseNumberController.text.isNotEmpty &&
        _selectedExpiryDate != null &&
        _selectedDocument != null &&
        _gstNumberController.text.isNotEmpty &&
        _panNumberController.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

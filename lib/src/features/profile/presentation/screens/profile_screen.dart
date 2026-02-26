import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:med_shakthi/src/features/profile/presentation/screens/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/core/utils/app_constants.dart';
import 'package:med_shakthi/src/features/support/presentation/screens/support_webview_screen.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/address_management_screen.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/payment_method_screen.dart';
import 'package:med_shakthi/src/features/cart/data/cart_data.dart';
import '../../../orders/orders_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  File? _profileImage;
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;

  String _email = '';
  String _displayName = 'User';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final metaName =
          user.userMetadata?['name'] ?? user.userMetadata?['full_name'];
      setState(() {
        _email = user.email ?? '';
        _phone = user.phone ?? '';
        _displayName =
            metaName ?? (_email.isNotEmpty ? _email.split('@')[0] : 'User');
      });
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _displayName = data['name'] ?? _displayName;
          _phone = data['phone'] ?? _phone;
          _avatarUrl = data['avatar_url'] as String?;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      context.read<CartData>().clearLocalStateOnly();
      await supabase.auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: const Color(0xFF4C8077),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );
    if (croppedFile == null) return;

    setState(() {
      _profileImage = File(croppedFile.path);
      _isUploadingAvatar = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final rawBytes = await croppedFile.readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 256,
        minHeight: 256,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      const fileName = 'avatar.jpg';
      final storagePath = '${user.id}/$fileName';

      await supabase.storage
          .from('avatars')
          .uploadBinary(
            storagePath,
            compressed,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(storagePath);
      final cacheBustedUrl =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await supabase
          .from('users')
          .update({'avatar_url': cacheBustedUrl})
          .eq('id', user.id);

      if (mounted) {
        setState(() => _avatarUrl = cacheBustedUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: Color(0xFF4C8077),
          ),
        );
      }
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload photo: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _showEditProfileSheet() async {
    final nameCtrl = TextEditingController(text: _displayName);
    // Holds the full international number written back by IntlPhoneField
    String completePhone = _phone;
    bool phoneValid = _phone.isNotEmpty;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(
        nameCtrl: nameCtrl,
        initialPhone: _phone,
        onPhoneChanged: (full, valid) {
          completePhone = full;
          phoneValid = valid;
        },
        onSave: () async {
          if (!phoneValid && completePhone.isNotEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid phone number.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          final user = supabase.auth.currentUser;
          if (user == null) return;
          final messenger = ScaffoldMessenger.of(ctx);
          final nav = Navigator.of(ctx);
          try {
            await supabase
                .from('users')
                .update({
                  'name': nameCtrl.text.trim(),
                  'phone': completePhone,
                })
                .eq('id', user.id);
            if (mounted) {
              setState(() {
                _displayName = nameCtrl.text.trim();
                _phone = completePhone;
              });
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Profile updated!'),
                  backgroundColor: Color(0xFF6AA39B),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = const Color(0xFF6AA39B);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Premium Profile Header ──────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF2A4A45), const Color(0xFF1A2F2D)]
                            : [
                                const Color(0xFF6AA39B),
                                const Color(0xFF4C8077),
                              ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          children: [
                            // Top row: title + settings icon
                            Row(
                              children: [
                                Text(
                                  'My Account',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Avatar + name row
                            Row(
                              children: [
                                // Avatar
                                GestureDetector(
                                  onTap: _isUploadingAvatar
                                      ? null
                                      : _pickProfileImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _isUploadingAvatar
                                              ? Container(
                                                  color: Colors.white24,
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                              : _profileImage != null
                                              ? Image.file(
                                                  _profileImage!,
                                                  fit: BoxFit.cover,
                                                )
                                              : (_avatarUrl != null &&
                                                    _avatarUrl!.isNotEmpty)
                                              ? Image.network(
                                                  _avatarUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, _) =>
                                                      _avatarPlaceholder(
                                                        primary,
                                                      ),
                                                )
                                              : _avatarPlaceholder(primary),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: primary,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            size: 14,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_email.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _email,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      if (_phone.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _phone,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Edit button
                                GestureDetector(
                                  onTap: _showEditProfileSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Menu Items ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section: Account
                        _sectionLabel('Account'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.location_on_outlined,
                              label: 'My Addresses',
                              color: Colors.blue,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddressManagementScreen(),
                                ),
                              ),
                            ),
                            _MenuItem(
                              icon: Icons.shopping_bag_outlined,
                              label: 'My Orders',
                              color: Colors.orange,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrdersPage(),
                                ),
                              ),
                            ),
                            _MenuItem(
                              icon: Icons.credit_card_outlined,
                              label: 'Payment Methods',
                              color: Colors.purple,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentMethodScreen(
                                    isCheckout: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section: Preferences
                        _sectionLabel('Preferences'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              color: Colors.grey,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              ),
                            ),
                            _MenuItem(
                              icon: Icons.headset_mic_outlined,
                              label: 'Help & Support',
                              color: Colors.teal,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SupportWebViewScreen(
                                    supportUrl: AppConstants.supportUrl,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _avatarPlaceholder(Color primary) {
    return Container(
      color: primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(
          context,
        ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
      ),
    );
  }
}

/* ─────────────── Edit Profile Bottom Sheet ─────────────── */

class _EditProfileSheet extends StatefulWidget {
  final TextEditingController nameCtrl;
  final String initialPhone;
  final void Function(String completeNumber, bool isValid) onPhoneChanged;
  final Future<void> Function() onSave;

  const _EditProfileSheet({
    required this.nameCtrl,
    required this.initialPhone,
    required this.onPhoneChanged,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  bool _isSaving = false;

  // Extract just the national number from a full international string like +919876543210
  String _extractNationalNumber(String fullPhone) {
    if (fullPhone.isEmpty) return '';
    // Strip the leading +XX or +XXX dial code heuristically — IntlPhoneField
    // will handle the rest; we just seed the number part.
    final digits = fullPhone.replaceAll(RegExp(r'\D'), '');
    // Return last 10 digits as a safe fallback
    if (digits.length > 10) return digits.substring(digits.length - 10);
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF6AA39B);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Name field ──────────────────────────
            TextField(
              controller: widget.nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Phone field with country picker ─────
            IntlPhoneField(
              initialValue: _extractNationalNumber(widget.initialPhone),
              initialCountryCode: 'IN',
              keyboardType: TextInputType.phone,
              showDropdownIcon: true,
              dropdownIconPosition: IconPosition.trailing,
              dropdownIcon: Icon(
                Icons.arrow_drop_down_rounded,
                color: primary,
                size: 20,
              ),
              flagsButtonPadding: const EdgeInsets.only(left: 12, right: 4),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              onChanged: (phone) {
                widget.onPhoneChanged(
                  phone.completeNumber,
                  phone.isValidNumber(),
                );
              },
              onCountryChanged: (country) {
                // country changed — number validity re-evaluated on next onChanged
              },
            ),
            const SizedBox(height: 24),

            // ── Save button ─────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        await widget.onSave();
                        if (mounted) setState(() => _isSaving = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────── Menu Card Widget ─────────────── */

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(i == 0 ? 16 : 0),
                  topRight: Radius.circular(i == 0 ? 16 : 0),
                  bottomLeft: Radius.circular(i == items.length - 1 ? 16 : 0),
                  bottomRight: Radius.circular(i == items.length - 1 ? 16 : 0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 20, color: item.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }
}

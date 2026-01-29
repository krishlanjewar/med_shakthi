import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AddressModel.dart';

class AddressStore extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<AddressModel> addresses = [];
  bool loading = false;

  AddressModel? get selectedAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isSelected,
      orElse: () => addresses.first,
    );
  }

  Future<void> fetchAddresses() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      final data = await supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      addresses = (data as List).map((e) => AddressModel.fromMap(e)).toList();

      if (addresses.isNotEmpty) {
        addresses = addresses
            .asMap()
            .entries
            .map((entry) => entry.value.copyWith(isSelected: entry.key == 0))
            .toList();
      }
    } catch (e) {
      debugPrint("fetchAddresses error: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> addAddress(AddressModel address) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      await supabase.from('addresses').insert(address.toMap());

      await fetchAddresses(); //  refresh from DB
    } catch (e) {
      debugPrint("addAddress error: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> updateAddress(AddressModel address) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      await supabase
          .from('addresses')
          .update(address.toMap())
          .eq('id', address.id)
          .eq('user_id', user.id);

      await fetchAddresses(); // Refresh list
    } catch (e) {
      debugPrint("updateAddress error: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Optimistic Update: Remove locally first
    final previousAddresses = List<AddressModel>.from(addresses);
    addresses.removeWhere((a) => a.id == id);
    notifyListeners();

    try {
      debugPrint("Attempting to delete address: $id for user: ${user.id}");

      // Use select() to get back deleted rows to confirm deletion
      final response = await supabase
          .from('addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)
          .select();

      debugPrint("Delete response: $response");

      if (response.isEmpty) {
        debugPrint(
          "WARNING: Delete returned empty list. ID might not match or RLS issue.",
        );
        // If delete failed logic-wise (no rows found), maybe we should Revert?
        // Or strictly trust the backend and revert.
        // For now, let's revert to show the user it failed.
        addresses = previousAddresses;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("deleteAddress error: $e");
      // Revert if exception
      addresses = previousAddresses;
      notifyListeners();
    }
  }

  void selectAddressLocal(String id) {
    addresses = addresses
        .map((a) => a.copyWith(isSelected: a.id == id))
        .toList();
    notifyListeners();
  }
}

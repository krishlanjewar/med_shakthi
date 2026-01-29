import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AddressModel.dart';
import 'AddressStore.dart';
import 'paymentMethodScreen.dart';

class AddressSelectScreen extends StatefulWidget {
  const AddressSelectScreen({super.key});

  @override
  State<AddressSelectScreen> createState() => _AddressSelectScreenState();
}

class _AddressSelectScreenState extends State<AddressSelectScreen> {
  GoogleMapController? mapController;
  LatLng selectedLatLng = const LatLng(28.6139, 77.2090);
  String addressText = "Tap on map to select address";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AddressStore>().fetchAddresses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddress(LatLng pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isEmpty) return;

      final p = placemarks.first;

      setState(() {
        addressText =
            "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.postalCode ?? ''}";
      });
    } catch (e) {
      setState(() {
        addressText = "Address not found";
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        setState(() => selectedLatLng = latLng);

        await _getAddress(latLng);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Address not found")));
    }
  }

  void _showAddAddressBottomSheet({AddressModel? addressToEdit}) {
    if (addressToEdit != null) {
      _searchController.text = addressToEdit.fullAddress;
      selectedLatLng = LatLng(addressToEdit.lat, addressToEdit.lng);
      addressText = addressToEdit.fullAddress;
      // Animate map to existing location
      Future.delayed(const Duration(milliseconds: 500), () {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selectedLatLng, 15),
        );
      });
    } else {
      _searchController.clear();
      // Default location or current location logic
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search for address",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: _searchAddress,
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: selectedLatLng,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      mapController = controller;
                      if (addressToEdit != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(selectedLatLng, 15),
                        );
                      }
                    },
                    onTap: (pos) async {
                      setState(() => selectedLatLng = pos);
                      await _getAddress(pos);
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId("selected"),
                        position: selectedLatLng,
                      ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        addressText,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () async {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User not logged in"),
                              ),
                            );
                            return;
                          }

                          if (addressText == "Tap on map to select address" ||
                              addressText == "Address not found") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select valid address"),
                              ),
                            );
                            return;
                          }

                          // If editing, preserve ID, else generate new
                          final newAddress = AddressModel(
                            id:
                                addressToEdit?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            userId: user.id,
                            title: "Home", // Could allow user to edit title too
                            fullAddress: addressText,
                            lat: selectedLatLng.latitude,
                            lng: selectedLatLng.longitude,
                            isSelected: addressToEdit?.isSelected ?? false,
                          );

                          if (addressToEdit != null) {
                            await context.read<AddressStore>().updateAddress(
                              newAddress,
                            );
                          } else {
                            await context.read<AddressStore>().addAddress(
                              newAddress,
                            );
                          }

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        child: Text(
                          addressToEdit != null
                              ? "Update Address"
                              : "Save Address",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AddressStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Address"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddAddressBottomSheet(),
            icon: const Icon(Icons.add),
            tooltip: "Add New Address",
          ),
        ],
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.addresses.isEmpty
          ? const Center(child: Text("No address saved yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.addresses.length,
              itemBuilder: (_, i) {
                final address = store.addresses[i];

                // Wrap item in Dismissible for delete functionality
                return Dismissible(
                  key: Key(address.id),
                  direction:
                      DismissDirection.startToEnd, // Swipe Right to Delete
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Address"),
                        content: const Text(
                          "Are you sure you want to delete this address?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    store.deleteAddress(address.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Address deleted successfully"),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      store.selectAddressLocal(address.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: address.isSelected
                              ? Colors.teal
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 1. Radio Button for Selection
                          Transform.scale(
                            scale: 1.2,
                            child: Radio<String>(
                              value: address.id,
                              groupValue: store.selectedAddress?.id,
                              activeColor: Colors.teal,
                              onChanged: (val) {
                                if (val != null) store.selectAddressLocal(val);
                              },
                            ),
                          ),

                          // 2. Address Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: address.isSelected
                                        ? Colors.teal
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.fullAddress,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // 3. Edit (Pencil) Button
                          IconButton(
                            onPressed: () {
                              _showAddAddressBottomSheet(
                                addressToEdit: address,
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // Proceed to Payment
            if (store.selectedAddress == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select an address")),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentMethodScreen()),
            );
          },
          child: const Text(
            "Proceed to Payment",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

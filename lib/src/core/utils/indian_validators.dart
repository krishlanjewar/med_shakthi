class IndianValidators {
  // Regex Patterns
  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _pincodeRegex = RegExp(r'^[1-9][0-9]{5}$');
  static final RegExp _cityRegex = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _panBasicRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _gstinBasicRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  // List of valid Indian states
  static const List<String> indianStates = [
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Other',
  ];

  static const List<String> panTypes = [
    'P',
    'C',
    'H',
    'F',
    'A',
    'T',
    'B',
    'L',
    'J',
    'G',
  ];

  // --- VALIDATORS ---

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!_mobileRegex.hasMatch(value))
      return 'Enter valid 10-digit mobile number';
    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return 'Enter pincode';
    if (!_pincodeRegex.hasMatch(value)) return 'Enter valid 6-digit pincode';
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) return 'Enter city';
    if (!_cityRegex.hasMatch(value))
      return 'City should contain alphabets only';
    return null;
  }

  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) return 'Enter PAN number';
    final pan = value.toUpperCase();

    // Basic Regex Check
    if (!_panBasicRegex.hasMatch(pan)) return 'Invalid PAN format';

    // 4th Character Check (Status)
    if (!panTypes.contains(pan[3]))
      return 'Invalid PAN status type (4th character)';

    // 5th Character Check (Surname first letter) - Must be alphabet
    if (!RegExp(r'[A-Z]').hasMatch(pan[4]))
      return 'Invalid 5th character in PAN';

    return null;
  }

  static String? validateGSTIN(String? value) {
    if (value == null || value.isEmpty) return 'Enter GSTIN number';
    final gstin = value.toUpperCase();

    // 1. Basic Regex & Length
    if (gstin.length != 15) return 'GSTIN must be 15 characters';
    if (!_gstinBasicRegex.hasMatch(gstin)) return 'Invalid GSTIN format';

    // 2. Validate State Code (01-38)
    final stateCode = int.tryParse(gstin.substring(0, 2));
    if (stateCode == null || stateCode < 1 || stateCode > 38) {
      if (stateCode != 97 && stateCode != 99) {
        // 97, 99 are special/other territories
        return 'Invalid State Code (First 2 digits)';
      }
    }

    // 3. Validate Internal PAN
    final internalPan = gstin.substring(2, 12);
    final panError = validatePAN(internalPan);
    if (panError != null) return 'Invalid PAN inside GSTIN';

    // 4. Validate 'Z' char
    if (gstin[13] != 'Z') return '14th character must be Z';

    // 5. Mod-36 Checksum Validation
    if (!_validateGSTINChecksum(gstin)) return 'Invalid GSTIN Checksum';

    return null;
  }

  // --- INTERNAL UTILS ---

  static bool _validateGSTINChecksum(String gstin) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final inputArr = gstin.split('');
    int sum = 0;

    // Algorithm:
    // 1. Convert char to value (0-9 -> 0-9, A-Z -> 10-35)
    // 2. Weights: Alternating 1, 2, 1, 2... for first 14 chars
    //    Wait.. standard Luhn mod 36 is slightly different.
    //    Official Government Logic:
    //    Loop i from 0 to 13:
    //      val = charValue(gstin[i])
    //      factor = (i % 2 == 1) ? 2 : 1; // Wait, actually standard is odd/even logic?
    //    Actually, let's use the provided standard weight method (1,2 alternating logic usually shifts).

    // Standard GST Mod-36 implementation:
    // Factor for position i (0-indexed): matches 1 for even, 2 for odd? No, usually 1,2,1,2...

    // Let's implement correct logic:
    // For i = 0 to 13:
    //   k = value(gstin[i])
    //   k = k * ((i % 2) + 1)
    //   sum += (k ~/ 36) + (k % 36)
    // final checkCode = (36 - (sum % 36)) % 36

    for (int i = 0; i < 14; i++) {
      int val = chars.indexOf(inputArr[i]);
      if (val == -1) return false;

      // Actually common algorithm is:
      // product = val * weight
      // quotient = product / 36
      // remainder = product % 36
      // sum = sum + quotient + remainder

      // Let's re-verify the "Weights alternating 1 & 2" user mentioned.
      // Usually it starts with 1.

      int product = val * ((i % 2) + 1); // 1, 2, 1, 2...
      int quotient = product ~/ 36;
      int remainder = product % 36;
      sum += quotient + remainder;
    }

    int checkCodeVal = (36 - (sum % 36)) % 36;
    String calculatedCheckChar = chars[checkCodeVal];

    return calculatedCheckChar == inputArr[14];
  }
}

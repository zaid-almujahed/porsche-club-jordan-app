import 'dart:typed_data';

/// API-independent data collected by the registration feature.
///
/// JSON keys, multipart field names, and endpoint formatting belong in
/// RegistrationSubmissionModel and the remote data source.
class RegistrationSubmission {
  const RegistrationSubmission({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.password,
    required this.dateOfBirth,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vin,
    required this.licensePlate,
    required this.profilePhotoName,
    required this.profilePhotoBytes,
    required this.licensePhotoName,
    required this.licensePhotoBytes,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String city;
  final String password;
  final DateTime dateOfBirth;
  final String vehicleModel;
  final int vehicleYear;
  final String vin;
  final String licensePlate;
  final String profilePhotoName;
  final Uint8List profilePhotoBytes;
  final String licensePhotoName;
  final Uint8List licensePhotoBytes;
}

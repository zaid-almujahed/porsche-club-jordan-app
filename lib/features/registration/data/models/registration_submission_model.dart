import 'dart:typed_data';

import '../../domain/entities/registration_submission.dart';

class RegistrationSubmissionModel {
  const RegistrationSubmissionModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.city,
    required this.dateOfBirth,
    required this.password,
    required this.vehicleVin,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.licensePlate,
    required this.profilePhotoName,
    required this.profilePhotoBytes,
    required this.licensePhotoName,
    required this.licensePhotoBytes,
  });

  factory RegistrationSubmissionModel.fromEntity(
    RegistrationSubmission submission,
  ) {
    return RegistrationSubmissionModel(
      fullName: submission.fullName,
      phoneNumber: submission.phoneNumber,
      email: submission.email,
      city: submission.city,
      dateOfBirth: submission.dateOfBirth,
      password: submission.password,
      vehicleVin: submission.vin,
      vehicleModel: submission.vehicleModel,
      vehicleYear: submission.vehicleYear,
      licensePlate: submission.licensePlate,
      profilePhotoName: submission.profilePhotoName,
      profilePhotoBytes: submission.profilePhotoBytes,
      licensePhotoName: submission.licensePhotoName,
      licensePhotoBytes: submission.licensePhotoBytes,
    );
  }

  final String fullName;
  final String phoneNumber;
  final String email;
  final String city;
  final DateTime dateOfBirth;
  final String password;
  final String vehicleVin;
  final String vehicleModel;
  final int vehicleYear;
  final String licensePlate;
  final String profilePhotoName;
  final Uint8List profilePhotoBytes;
  final String licensePhotoName;
  final Uint8List licensePhotoBytes;

  /// Exact multipart field names published by the PCJ API documentation.
  Map<String, String> toFields() {
    return <String, String>{
      'name': fullName,
      'phone': phoneNumber,
      'email': email,
      'city': city,
      'date_of_birth': _formatDate(dateOfBirth),
      'password': password,
      'car_vin': vehicleVin,
      'car_model': vehicleModel,
      'car_year': vehicleYear.toString(),
      'license_plate': licensePlate,
    };
  }

  static String _formatDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }
}

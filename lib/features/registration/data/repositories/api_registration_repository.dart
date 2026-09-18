import 'package:pcj_v4/core/network/pcj_api_client.dart';
import 'package:pcj_v4/features/registration/domain/entities/registration_submission.dart';
import 'package:pcj_v4/features/registration/domain/repositories/registration_repository.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';

import '../models/registration_submission_model.dart';

class ApiRegistrationRepository implements RegistrationRepository {
  ApiRegistrationRepository({required PcjApiClient apiClient})
    : _apiClient = apiClient;

  final PcjApiClient _apiClient;

  // Exact purpose value supplied for registration OTP verification/resend.
  static const String _registrationOtpPurpose = 'register';

  @override
  Future<User> submitApplication(RegistrationSubmission submission) async {
    final RegistrationSubmissionModel request =
        RegistrationSubmissionModel.fromEntity(submission);
    await _apiClient.multipart(
      '/auth/register',
      method: 'POST',
      fields: request.toFields(),
      files: <ApiUpload>[
        ApiUpload(
          field: 'userphoto',
          fileName: request.profilePhotoName,
          bytes: request.profilePhotoBytes,
        ),
        ApiUpload(
          // This spelling intentionally matches the published API contract.
          field: 'licens_plate_photo',
          fileName: request.licensePhotoName,
          bytes: request.licensePhotoBytes,
        ),
      ],
      authenticated: false,
    );

    // The documented register response is a message, not a user object. This
    // local projection keeps the status screen usable until the next sign-in
    // refreshes the authoritative user from /auth/me.
    return User(
      id: submission.email,
      name: submission.fullName,
      email: submission.email,
      phoneNumber: submission.phoneNumber,
      city: submission.city,
      dateOfBirth: submission.dateOfBirth,
      applicationStatus: ApplicationStatus.pending,
      membershipStatus: MembershipStatus.inactive,
      vehicles: <Vehicle>[
        Vehicle(
          id: submission.vin,
          model: submission.vehicleModel,
          year: submission.vehicleYear,
          exteriorColor: '',
          vin: submission.vin,
          licensePlate: submission.licensePlate,
        ),
      ],
    );
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    await _apiClient.postForm(
      '/auth/verify-otp',
      fields: <String, Object?>{
        'email': email.trim(),
        'otp': otp.trim(),
        'purpose': _registrationOtpPurpose,
      },
      authenticated: false,
    );
  }

  @override
  Future<void> resendEmailOtp({required String email}) async {
    await _apiClient.post(
      '/auth/resend-otp',
      query: <String, Object?>{
        'email': email.trim(),
        'purpose': _registrationOtpPurpose,
      },
      authenticated: false,
    );
  }
}

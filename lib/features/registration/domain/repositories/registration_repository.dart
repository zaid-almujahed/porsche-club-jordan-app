import 'package:pcj_v4/shared/domain/entities/user.dart';

import '../entities/registration_submission.dart';

abstract interface class RegistrationRepository {
  Future<User> submitApplication(RegistrationSubmission submission);

  Future<void> verifyEmailOtp({required String email, required String otp});

  Future<void> resendEmailOtp({required String email});
}

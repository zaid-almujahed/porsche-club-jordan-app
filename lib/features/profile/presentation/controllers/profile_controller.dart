import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/services/image_picker_service.dart';
import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';

import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository repository,
    required ImagePickerService imagePickerService,
  }) : _repository = repository,
       _imagePickerService = imagePickerService;

  final ProfileRepository _repository;
  final ImagePickerService _imagePickerService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  AsyncState<User> _profile = const AsyncState<User>.initial();
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isPerformingAccountAction = false;
  Object? _actionError;

  AsyncState<User> get profile => _profile;
  User? get user => _profile.data;
  List<Vehicle> get vehicles => user?.vehicles ?? const <Vehicle>[];
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  bool get isPerformingAccountAction => _isPerformingAccountAction;
  Object? get actionError => _actionError;

  Future<void> load({bool force = false}) async {
    if (!force && (_profile.isLoading || _profile.hasData)) return;
    _profile = AsyncState<User>.loading(previousData: user);
    notifyListeners();
    try {
      final User value = await _repository.getProfile();
      _setUser(value);
    } catch (error, stackTrace) {
      _profile = AsyncState<User>.failure(
        error,
        stackTrace,
        previousData: user,
      );
    }
    notifyListeners();
  }

  void _setUser(User value) {
    _profile = AsyncState<User>.success(value);
    nameController.text = value.name;
    emailController.text = value.email;
    phoneController.text = value.phoneNumber;
    cityController.text = value.city ?? '';
    dateOfBirthController.text = _formatDate(value.dateOfBirth);
  }

  Future<bool> saveProfile() async {
    if (_isSaving) return false;
    _isSaving = true;
    _actionError = null;
    notifyListeners();
    try {
      final User value = await _repository.updateProfile(
        ProfileUpdate(
          name: nameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          city: cityController.text.trim(),
          dateOfBirth: _parseDate(dateOfBirthController.text),
        ),
      );
      _setUser(value.copyWith(vehicles: vehicles));
      return true;
    } catch (error) {
      _actionError = error;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void setDateOfBirth(DateTime value) {
    dateOfBirthController.text = _formatDate(value);
    notifyListeners();
  }

  Future<void> changeAvatar() async {
    if (_isUploadingAvatar) return;
    _isUploadingAvatar = true;
    _actionError = null;
    notifyListeners();
    try {
      final XFile? image = await _imagePickerService.pickFromGallery();
      if (image == null) return;
      final User value = await _repository.uploadAvatar(
        AvatarUpload(bytes: await image.readAsBytes(), fileName: image.name),
      );
      _setUser(value.copyWith(vehicles: vehicles));
    } catch (error) {
      _actionError = error;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    if (_isPerformingAccountAction) return;
    _isPerformingAccountAction = true;
    _actionError = null;
    notifyListeners();
    try {
      throw const UnsupportedApiOperationException(
        'The PCJ API does not currently provide a vehicle deletion endpoint.',
      );
    } catch (error) {
      _actionError = error;
    } finally {
      _isPerformingAccountAction = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmail(String email) async {
    final String value = email.trim();
    if (value.isEmpty || !_looksLikeEmail(value)) {
      _actionError = const AppException('Enter a valid email address.');
      notifyListeners();
      return false;
    }
    return _runAccountAction(() async {
      await _repository.updateEmail(value);
      await load(force: true);
    });
  }

  Future<bool> updatePhoneNumber(String phoneNumber) async {
    return _runAccountAction(() async {
      final User? current = user;
      if (current == null) {
        throw const AppException('Load the profile before updating it.');
      }
      await _repository.updateProfile(
        ProfileUpdate(
          name: current.name,
          phoneNumber: phoneNumber.trim(),
          city: current.city,
          dateOfBirth: current.dateOfBirth,
        ),
      );
      await load(force: true);
    });
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _runAccountAction(() async {
      throw const UnsupportedApiOperationException(
        'Use the documented password-reset flow to change your password.',
      );
    });
  }

  Future<bool> deleteAccount() {
    return _runAccountAction(_repository.deleteAccount);
  }

  Future<bool> _runAccountAction(Future<void> Function() action) async {
    if (_isPerformingAccountAction) return false;
    _isPerformingAccountAction = true;
    _actionError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error) {
      _actionError = error;
      return false;
    } finally {
      _isPerformingAccountAction = false;
      notifyListeners();
    }
  }

  void reset() {
    _profile = const AsyncState<User>.initial();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    cityController.clear();
    dateOfBirthController.clear();
    _isSaving = false;
    _isUploadingAvatar = false;
    _isPerformingAccountAction = false;
    _actionError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '';
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static DateTime? _parseDate(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) return null;
    final DateTime? parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      throw const AppException('Enter the date of birth as YYYY-MM-DD.');
    }
    return parsed;
  }

  static bool _looksLikeEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }
}

import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class UpdateAddressUseCase {
  UpdateAddressUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String addressLine,
    required String country,
    required String city,
    required String zipCode,
  }) {
    return _repository.updateAddress(
      addressLine: addressLine,
      country: country,
      city: city,
      zipCode: zipCode,
    );
  }
}

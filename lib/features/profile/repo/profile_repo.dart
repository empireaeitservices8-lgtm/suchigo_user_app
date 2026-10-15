import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileResponseModel> getProfile({
    Function(AppError error)? onError,
  });
}

class ProfileRepositoryImpl implements ProfileRepository {
  final WebAPIService _apiService;

  ProfileRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<ProfileResponseModel> getProfile({
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    return _apiService.executeAPI<ProfileResponseModel>(
      methodToCall: _apiService.dio.get(urlProfile),
      converter: ProfileResponseModel.fromJson,
      onError: onError,
    );
  }
}

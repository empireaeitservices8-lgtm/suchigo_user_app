import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/rewards_model.dart';
import '../repo/rewards_repo.dart';

class MyRewardsViewModel extends ViewModel {
  final RewardsRepository _repository;
  RewardsSummaryModel _rewardsSummary = const RewardsSummaryModel();
  String? _errorMessage;

  MyRewardsViewModel({RewardsRepository? repository})
      : _repository = repository ?? RewardsRepositoryImpl() {
    loadRewards();
  }

  RewardsSummaryModel get rewardsSummary => _rewardsSummary;
  String? get errorMessage => _errorMessage;

  Future<void> loadRewards() async {
    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rewardsSummary = await _repository.getRewardsData(
        onError: (error) {
          _errorMessage = error.message;
        },
      );
    } catch (e) {
      _errorMessage ??= 'Failed to load rewards details';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

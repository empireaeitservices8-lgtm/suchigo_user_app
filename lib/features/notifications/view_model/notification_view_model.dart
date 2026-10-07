import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/notification_model.dart';
import '../repo/notification_repo.dart';

class NotificationViewModel extends ViewModel {
  final NotificationRepository _repository;

  NotificationFilter _selectedFilter = NotificationFilter.all;
  List<NotificationItemModel> _allNotifications = [];

  NotificationViewModel({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryImpl() {
    fetchNotifications();
  }

  NotificationFilter get selectedFilter => _selectedFilter;
  List<NotificationItemModel> get allNotifications => _allNotifications;

  List<NotificationItemModel> get filteredNotifications {
    switch (_selectedFilter) {
      case NotificationFilter.all:
        return _allNotifications;
      case NotificationFilter.upcoming:
        return _allNotifications
            .where((item) => item.type == NotificationFilter.upcoming)
            .toList();
      case NotificationFilter.delivered:
        return _allNotifications
            .where((item) => item.type == NotificationFilter.delivered)
            .toList();
    }
  }

  void setFilter(NotificationFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void fetchNotifications() async {
    isLoading = true;
    try {
      _allNotifications = await _repository.getNotifications();
    } catch (e) {
      _allNotifications = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String id) async {
    await _repository.markAsRead(id);
    final index = _allNotifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = NotificationItemModel(
        id: _allNotifications[index].id,
        title: _allNotifications[index].title,
        message: _allNotifications[index].message,
        dateTime: _allNotifications[index].dateTime,
        type: _allNotifications[index].type,
        isRead: true,
      );
      _allNotifications[index] = updatedItem;
      notifyListeners();
    }
  }
}

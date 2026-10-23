import 'package:suchigo_user_app/helpers/url_helpers.dart';

String urlBase = UrlHelpers.baseURL;

//Auth
String urlSendOTP = "${urlBase}otp/send/";
String urlVerifyOTP = "${urlBase}otp/verify/";
String urlRegister = "${urlBase}register/";
String urlLogin = "${urlBase}login/";
String urlProfile = "${urlBase}profile/";
String urlBills = "${urlBase}bill-history-from-collector/";
String urlBillHistoryFromCollector = "${urlBase}bill-history-from-collector/";
String urlPickups = "${urlBase}pickups/";
String urlRazorpayAddToWallet = "${urlBase}razorpay/add-to-wallet/";
String urlSubWasteTypes = "${urlBase}sub-waste-types/";
String urlStates = "${urlBase}states/";
String urlDistricts = "https://suchigo.pythonanywhere.com/api/districts/";
String urlLocalBodies = "https://suchigo.pythonanywhere.com/api/localbodies/";
String urlWards = "https://suchigo.pythonanywhere.com/api/wards/";
String urlDisposalRates = "https://suchigo.pythonanywhere.com/api/disposal-rates/";
String urlPickupVehicleTracking = "${urlBase}pickup-vehicle-tracking/";
String urlCalendarDates =
    "https://suchigoapis.pythonanywhere.com/api/calendar-dates/";

//Register
String urlRegistrationRequestOTP = "${urlBase}register/request-otp";
String urlRegistrationVerifyOTP = "${urlBase}register/verify-otp";
String urlRegistration = "${urlBase}register/store";

String urlLoginGenerateOrganization = "${urlBase}owner/mobile/login";
String urlLoginVerify = "${urlBase}owner/mobile/login/verify";
String urlGetDeviceUserCount = '${urlBase}owner/home/device-user-count';
String urlGetLicenseSummary = '${urlBase}owner/home/license-summary';
String urlGetDeviceList = '${urlBase}owner/device/list';
String urlGetDeviceGroupList = '${urlBase}owner/device-group/list';
String urlGetAddDeviceInDeviceGroup = '${urlBase}owner/device-group/add-device';
String urlGetAddDeviceGroup = '${urlBase}owner/device-group/add';
String urlGetDeviceGroupChangeName = '${urlBase}owner/device-group/change-name';
String urlGetDeviceGroupDeviceList = '${urlBase}owner/device-group/device-list';

String urlAddNewBTDevice = '${urlBase}owner/device/add';
String urlGetDeviceTypeList = '${urlBase}owner/device-type';
String urlGetRemoveDevice = '${urlBase}owner/device/remove';
String urlRemoveUserFromDeviceSharedList =
    '${urlBase}owner/device/device-key-revoke';
String urlGetUserDeleteDevice = '${urlBase}owner/user/delete-device';
String urlTransferDeviceKey = '${urlBase}owner/device/transfer-key/user';
String urlDeleteUserGroup = '${urlBase}owner/user-group/delete';
String urlAddUser = '${urlBase}owner/user/add';
String urlgetUserList = '${urlBase}owner/user/list';
String urlRemoveDeviceGroup = '${urlBase}owner/device-group/delete';
String urlAdminEnableBiometric = '${urlBase}owner/config/biometric-login/store';

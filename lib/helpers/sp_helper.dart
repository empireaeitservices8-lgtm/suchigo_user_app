import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpHelper {
  static SharedPreferences? _sp;
  static FlutterSecureStorage? _ss;

  static Future<SharedPreferences> getSP() async {
    _sp ??= await SharedPreferences.getInstance();
    await _sp!.reload();
    return _sp!;
  }

  static FlutterSecureStorage _secureInstance() {
    _ss ??= const FlutterSecureStorage();
    return _ss!;
  }

  ///
  ///## Save string in shared pref
  ///[key] name to save.
  ///can retreave saved string using [key]
  ///[secure] set true if you want to save string in secure storage.
  static Future<bool> saveString(String key, String value,
      {bool secure = false}) async {
    if (secure) {
      await _secureInstance().write(key: key, value: value);
      return true;
    }
    final sp = await getSP();
    return await sp.setString(key, value);
  }

  static Future<bool> remove(String key, {bool secure = false}) async {
    if (secure) {
      await _secureInstance().delete(key: key);
      return true;
    }
    final sp = await getSP();
    return await sp.remove(key);
  }

  static Future<bool> clearAuthSession() async {
    final sp = await getSP();
    try {
      await _secureInstance().deleteAll();
    } catch (_) {}
    await sp.remove('KEY_TOKEN');
    await sp.remove('KEY_USER_ID');
    await sp.remove('KEY_USER_NAME');
    await sp.remove('KEY_EMAIL');
    await sp.remove('KEY_USER_MOBILE');
    await sp.remove('KEY_ROLE_ID');
    await sp.remove('KEY_ROLE');
    await sp.remove('KEY_TENANT_CODE');
    await sp.remove('KEY_ONBOARDING_COMPLETED');
    await sp.remove('local_auth_status');
    return true;
  }

  static Future<bool> clearAll() async {
    final sp = await getSP();
    try {
      await _secureInstance().deleteAll();
    } catch (_) {}
    return await sp.clear();
  }

  ///
  ///## Read saved String
  ///[key] name given to save.
  ///[secure] true if String saved as secure.
  static Future<String?> getString(String key, {bool secure = false}) async {
    if (secure) {
      return await _secureInstance().read(key: key);
    }
    final sp = await getSP();
    return sp.getString(key);
  }

  ///
  ///## Read saved boolean
  ///[key] name given to save.
  static Future<bool?> getBoolean(String key) async {
    final sp = await getSP();
    return sp.getBool(key);
  }

  ///
  ///
  static Future<bool> saveBoolean(
    String key,
    bool value,
  ) async {
    final sp = await getSP();
    return await sp.setBool(key, value);
  }
}

extension RememberBool on bool {
  Future rememberMe(String name) async {
    await SpHelper.saveBoolean(name, this);
  }

  Future<bool> getMeBack(String name) async {
    return await SpHelper.getBoolean(name) ?? this;
  }
}

extension RememberString on String {
  rememberMe(String name) async {
    await SpHelper.saveString(name, this);
  }

  Future<String> getMeBack(String name) async {
    return await SpHelper.getString(name) ?? this;
  }
}

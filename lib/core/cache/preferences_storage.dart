import 'package:qrattendance/core/enums/app_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  final SharedPreferences _preferences;

  PreferencesStorage(this._preferences);

  /// ================= CLEAR =================
  Future<void> clear() async {
    await _preferences.clear();
  }

  /// ================= BOOLEAN =================
  Future<void> putBoolean({
    required PreferencesKeys key,
    required bool value,
  }) async {
    await _preferences.setBool(key.name, value);
  }

  bool getBoolean({required PreferencesKeys key, bool defaultValue = false}) {
    return _preferences.getBool(key.name) ?? defaultValue;
  }

  /// ================= STRING =================
  Future<bool> putString({
    required PreferencesKeys key,
    required String? value,
  }) async {
    return await _preferences.setString(key.name, value ?? "");
  }

  String? getString({required PreferencesKeys key}) {
    return _preferences.getString(key.name);
  }

  /// ================= TOKEN =================
  Future<void> saveUserToken(String token) async {
    await _preferences.setString(PreferencesKeys.userToken.name, token);
  }

  String? getUserToken() {
    return _preferences.getString(PreferencesKeys.userToken.name);
  }

  Future<void> deleteUserToken() async {
    await _preferences.remove(PreferencesKeys.userToken.name);
  }

  Future<void> saveRefreshToken(String token) async {
    await _preferences.setString(PreferencesKeys.refreshToken.name, token);
  }

  String? getRefreshToken() {
    return _preferences.getString(PreferencesKeys.refreshToken.name);
  }

  Future<void> deleteRefreshToken() async {
    await _preferences.remove(PreferencesKeys.refreshToken.name);
  }

  /// ================= USER ROLE =================
  Future<void> saveUserRole(bool isAdmin) async {
    await _preferences.setBool(PreferencesKeys.userIsAdmin.name, isAdmin);
  }

  bool isUserAdmin() {
    return _preferences.getBool(PreferencesKeys.userIsAdmin.name) ?? false;
  }

  Future<void> deleteUserRole() async {
    await _preferences.remove(PreferencesKeys.userIsAdmin.name);
  }

  Future<void> saveUserSecretKey(String secretKey) async {
    await _preferences.setString(PreferencesKeys.userSecretKey.name, secretKey);
  }

  String? getUserSecretKey() {
    return _preferences.getString(PreferencesKeys.userSecretKey.name);
  }

  Future<void> deleteUserSecretKey() async {
    await _preferences.remove(PreferencesKeys.userSecretKey.name);
  }

  Future<void> saveUserId(int userId) async {
    await _preferences.setInt(PreferencesKeys.userId.name, userId);
  }

  int? getUserId() {
    return _preferences.getInt(PreferencesKeys.userId.name);
  }

  Future<void> deleteUserId() async {
    await _preferences.remove(PreferencesKeys.userId.name);
  }

  Future<void> saveUserEmailConfirmed(bool confirmed) async {
    await putBoolean(key: PreferencesKeys.isEmailConfirmed, value: confirmed);
  }

  bool isUserEmailConfirmed() {
    return getBoolean(
      key: PreferencesKeys.isEmailConfirmed,
      defaultValue: true,
    );
  }

  Future<void> saveUserType(int userType) async {
    await _preferences.setInt(PreferencesKeys.userType.name, userType);
  }

  int? getUserType() {
    return _preferences.getInt(PreferencesKeys.userType.name);
  }

  Future<void> saveRoleId(int roleId) async {
    await _preferences.setInt(PreferencesKeys.roleId.name, roleId);
  }

  int? getRoleId() {
    return _preferences.getInt(PreferencesKeys.roleId.name);
  }

  Future<void> saveBranchId(int branchId) async {
    await _preferences.setInt(PreferencesKeys.branchId.name, branchId);
  }

  int? getBranchId() {
    return _preferences.getInt(PreferencesKeys.branchId.name);
  }

  Future<void> saveBranchName(String branchName) async {
    await _preferences.setString(PreferencesKeys.branchName.name, branchName);
  }

  String? getBranchName() {
    return _preferences.getString(PreferencesKeys.branchName.name);
  }

  Future<void> saveUserName(String name) async {
    await _preferences.setString(PreferencesKeys.name.name, name);
  }

  String? getUserName() {
    return _preferences.getString(PreferencesKeys.name.name);
  }

  Future<void> saveUserProfile(String profileJson) async {
    await _preferences.setString(PreferencesKeys.userProfile.name, profileJson);
  }

  String? getUserProfile() {
    return _preferences.getString(PreferencesKeys.userProfile.name);
  }

  Future<void> deleteUserProfile() async {
    await _preferences.remove(PreferencesKeys.userProfile.name);
  }

  Future<void> saveNeedsLocationPrompt(bool needsPrompt) async {
    await putBoolean(
      key: PreferencesKeys.needsLocationPrompt,
      value: needsPrompt,
    );
  }

  bool getNeedsLocationPrompt() {
    return getBoolean(
      key: PreferencesKeys.needsLocationPrompt,
      defaultValue: false,
    );
  }

  /// ================= LANGUAGE =================
  String getCurrentLanguage() {
    return _preferences.getString(PreferencesKeys.currentLanguage.name) ?? "en";
  }

  bool isEnglish() => getCurrentLanguage() == "en";
  bool isArabic() => getCurrentLanguage() == "ar";

  /// ================= CURRENCY =================
  String getCurrentCurrency() {
    return _preferences.getString(PreferencesKeys.currentCurrency.name) ??
        "EGP";
  }

  bool isEGP() => getCurrentCurrency() == "EGP";
  bool isUSD() => getCurrentCurrency() == "USD";
}

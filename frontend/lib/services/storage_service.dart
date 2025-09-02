// lib/services/storage_service.dart (수정됨)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  factory StorageService() => instance;

  /// 초기화 (앱 시작 시 호출)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences {
    if (_preferences == null) {
      throw Exception('StorageService가 초기화되지 않았습니다. init()를 먼저 호출하세요.');
    }
    return _preferences!;
  }

  // String 값 저장
  Future<bool> setString(String key, String value) async {
    return await preferences.setString(key, value);
  }

  // String 값 가져오기
  String? getString(String key) {
    return preferences.getString(key);
  }

  // int 값 저장
  Future<bool> setInt(String key, int value) async {
    return await preferences.setInt(key, value);
  }

  // int 값 가져오기
  int? getInt(String key) {
    return preferences.getInt(key);
  }

  // bool 값 저장
  Future<bool> setBool(String key, bool value) async {
    return await preferences.setBool(key, value);
  }

  // bool 값 가져오기
  bool? getBool(String key) {
    return preferences.getBool(key);
  }

  // double 값 저장
  Future<bool> setDouble(String key, double value) async {
    return await preferences.setDouble(key, value);
  }

  // double 값 가져오기
  double? getDouble(String key) {
    return preferences.getDouble(key);
  }

  // StringList 값 저장
  Future<bool> setStringList(String key, List<String> value) async {
    return await preferences.setStringList(key, value);
  }

  // StringList 값 가져오기
  List<String>? getStringList(String key) {
    return preferences.getStringList(key);
  }

  // 특정 키 삭제
  Future<bool> remove(String key) async {
    return await preferences.remove(key);
  }

  // 모든 데이터 삭제
  Future<bool> clear() async {
    return await preferences.clear();
  }

  // 키가 존재하는지 확인
  bool containsKey(String key) {
    return preferences.containsKey(key);
  }

  // 모든 키 목록 가져오기
  Set<String> getKeys() {
    return preferences.getKeys();
  }

  // ========== 토큰 관리 메서드들 ==========

  // 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await setString(AppConstants.accessTokenKey, token);
  }

  // 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    return getString(AppConstants.accessTokenKey);
  }

  // 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    await setString(AppConstants.refreshTokenKey, token);
  }

  // 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    return getString(AppConstants.refreshTokenKey);
  }

  // ========== 사용자 정보 관리 메서드들 ==========

  // 사용자 정보 저장
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await setString(AppConstants.userInfoKey, jsonEncode(userInfo));
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserInfo() async {
    final userInfoJson = getString(AppConstants.userInfoKey);
    if (userInfoJson != null) {
      return Map<String, dynamic>.from(jsonDecode(userInfoJson));
    }
    return null;
  }

  // 사용자 타입 저장
  Future<void> saveUserType(String userType) async {
    await setString('user_type', userType);
  }

  // 사용자 타입 가져오기
  Future<String?> getUserType() async {
    return getString('user_type');
  }

  // ========== 앱 상태 관리 메서드들 ==========

  // 첫 실행 여부 확인
  Future<bool> isFirstLaunch() async {
    return getBool('first_launch') ?? true;
  }

  // 첫 실행 완료 처리
  Future<void> setFirstLaunchCompleted() async {
    await setBool('first_launch', false);
  }

  // 로그인 상태 확인
  bool get isLoggedIn {
    final token = getString(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // ========== 인증 관련 정리 메서드들 ==========

  // 토큰만 삭제
  Future<void> clearTokens() async {
    await remove(AppConstants.accessTokenKey);
    await remove(AppConstants.refreshTokenKey);
  }

  // 모든 인증 데이터 삭제 (로그아웃 시 사용)
  Future<void> clearAll() async {
    await remove(AppConstants.accessTokenKey);
    await remove(AppConstants.refreshTokenKey);
    await remove(AppConstants.userInfoKey);
    await remove('user_type');
  }

  // ========== 일반 키-값 저장 메서드들 ==========

  Future<void> saveString(String key, String value) async {
    await setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await setBool(key, value);
  }

  Future<bool> getBoolValue(String key, {bool defaultValue = false}) async {
    return getBool(key) ?? defaultValue;
  }
}
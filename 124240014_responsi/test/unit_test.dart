import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_responsi/models/user_model.dart';
import 'package:latihan_responsi/services/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('UserModel maps local account data', () {
    final user = UserModel(id: 1, username: 'testuser', password: 'password');
    final fromMap = UserModel.fromMap(user.toMap());

    expect(fromMap.id, 1);
    expect(fromMap.username, 'testuser');
    expect(fromMap.password, 'password');
  });

  test('login session can be saved and cleared', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferenceService.instance;

    expect(await preferences.isLoggedIn(), isFalse);
    await preferences.saveLoginSession('testuser');
    expect(await preferences.isLoggedIn(), isTrue);
    expect(await preferences.getUsername(), 'testuser');

    await preferences.clearSession();
    expect(await preferences.isLoggedIn(), isFalse);
  });
}

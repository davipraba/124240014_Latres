import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_responsi/models/character_model.dart';
import 'package:latihan_responsi/models/episode_model.dart';
import 'package:latihan_responsi/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihan_responsi/services/preference_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Tests', () {
    test('UserModel mapping works correctly', () {
      final user = UserModel(id: 1, username: 'testuser', password: 'password123');
      final map = user.toMap();
      expect(map['username'], 'testuser');
      expect(map['password'], 'password123');

      final fromMap = UserModel.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.username, 'testuser');
    });

    test('CharacterModel fromApiJson and toJson', () {
      final apiJson = {
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin': {'name': 'Earth (C-137)'},
        'location': {'name': 'Citadel of Ricks'},
        'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        'episode': ['https://rickandmortyapi.com/api/episode/1', 'https://rickandmortyapi.com/api/episode/2'],
      };

      final char = CharacterModel.fromApiJson(apiJson);
      expect(char.id, 1);
      expect(char.name, 'Rick Sanchez');
      expect(char.status, 'Alive');
      expect(char.species, 'Human');
      expect(char.originName, 'Earth (C-137)');
      expect(char.locationName, 'Citadel of Ricks');
      expect(char.episodeCount, 2);

      final json = char.toJson();
      final fromJson = CharacterModel.fromJson(json);
      expect(fromJson.id, char.id);
      expect(fromJson.name, char.name);
      expect(fromJson.originName, 'Earth (C-137)');
      expect(fromJson.episodeCount, 2);
    });

    test('EpisodeModel fromJson', () {
      final epJson = {
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
        'characters': ['url1', 'url2', 'url3'],
      };

      final ep = EpisodeModel.fromJson(epJson);
      expect(ep.id, 1);
      expect(ep.name, 'Pilot');
      expect(ep.airDate, 'December 2, 2013');
      expect(ep.episode, 'S01E01');
      expect(ep.characterCount, 3);
    });
  });

  group('PreferenceService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Session login and logout flow', () async {
      final prefService = PreferenceService.instance;

      expect(await prefService.isLoggedIn(), isFalse);
      expect(await prefService.getUsername(), isNull);

      await prefService.saveLoginSession('rick');
      expect(await prefService.isLoggedIn(), isTrue);
      expect(await prefService.getUsername(), 'rick');

      await prefService.clearSession();
      expect(await prefService.isLoggedIn(), isFalse);
    });

    test('Favorite characters persist in SharedPreferences', () async {
      final prefService = PreferenceService.instance;
      final char1 = CharacterModel(
        id: 1,
        name: 'Rick Sanchez',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Male',
        originName: 'Earth',
        locationName: 'Earth',
        image: 'https://example.com/rick.png',
        episodeCount: 51,
      );

      expect(await prefService.getFavorites(), isEmpty);
      expect(await prefService.isFavorite(1), isFalse);

      await prefService.addFavorite(char1);
      expect(await prefService.isFavorite(1), isTrue);

      final list = await prefService.getFavorites();
      expect(list.length, 1);
      expect(list.first.name, 'Rick Sanchez');

      await prefService.removeFavorite(1);
      expect(await prefService.isFavorite(1), isFalse);
      expect(await prefService.getFavorites(), isEmpty);
    });
  });
}

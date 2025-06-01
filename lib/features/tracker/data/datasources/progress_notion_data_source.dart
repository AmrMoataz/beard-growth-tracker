import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:progress_tracker/features/tracker/data/datasources/progress_local_data_source.dart';
import 'package:progress_tracker/features/tracker/data/models/progress_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressNotionDataSource implements ProgressLocalDataSource {
  static const String _baseUrl = 'https://api.notion.com/v1';
  static const String _apiVersion = '2022-06-28';
  static const String _databaseIdKey = 'notion_database_id';
  final String _apiToken;
  final SharedPreferences _sharedPreferences;
  final http.Client _httpClient;

  ProgressNotionDataSource({
    required SharedPreferences sharedPreferences,
    http.Client? httpClient,
    String? apiToken,
  })  : _sharedPreferences = sharedPreferences,
        _httpClient = httpClient ?? http.Client(),
        _apiToken =
            apiToken ?? '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';

  /// Get the database ID from shared preferences or create a new database
  Future<String> _getDatabaseId() async {
    final savedId = _sharedPreferences.getString(_databaseIdKey);
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    // Find or create a database
    final dbId = await _findOrCreateDatabase();
    await _sharedPreferences.setString(_databaseIdKey, dbId);
    return dbId;
  }

  /// Find an existing database or create a new one
  Future<String> _findOrCreateDatabase() async {
    // First, try to find an existing Progress Tracker database
    final existingDb = await _searchForDatabase('Progress Tracker');
    if (existingDb != null) {
      return existingDb;
    }

    // Create a new database if none exists
    return await _createNewDatabase();
  }

  /// Search for a database by title
  Future<String?> _searchForDatabase(String query) async {
    final url = Uri.parse('$_baseUrl/search');

    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'query': query,
        'filter': <String, String>{'property': 'object', 'value': 'database'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      if (results.isNotEmpty) {
        return results.first['id'] as String;
      }
    }

    return null;
  }

  /// Create a new Notion database
  Future<String> _createNewDatabase() async {
    // First get a list of pages the user has access to
    final parentPage = await _getFirstAccessiblePage();
    if (parentPage == null) {
      throw Exception(
          'Could not find any accessible pages to create database in');
    }

    final url = Uri.parse('$_baseUrl/databases');

    // Database creation follows the format specified in Notion API
    // https://developers.notion.com/reference/create-a-database
    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'parent': <String, dynamic>{
          'type': 'page_id',
          'page_id': parentPage,
        },
        // Title for the database
        'title': [
          <String, dynamic>{
            'type': 'text',
            'text': <String, dynamic>{
              'content': 'Progress Tracker',
            },
          },
        ],
        // Description for the database (optional)
        'description': [
          <String, dynamic>{
            'type': 'text',
            'text': <String, dynamic>{
              'content': 'Tracking daily beard growth progress',
            },
          },
        ],
        // Schema properties definition
        'properties': <String, dynamic>{
          // The Name property serves as the title column
          'Name': <String, dynamic>{
            'title': <String, dynamic>{}
          },
          'Date': <String, dynamic>{
            'date': <String, dynamic>{}
          },
          'Morning Application': <String, dynamic>{
            'checkbox': <String, dynamic>{}
          },
          'Evening Application': <String, dynamic>{
            'checkbox': <String, dynamic>{}
          },
          'Notes': <String, dynamic>{
            'rich_text': <String, dynamic>{}
          },
          'Photo URL': <String, dynamic>{
            'url': <String, dynamic>{}
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['id'] as String;
    } else {
      throw Exception('Failed to create database: ${response.body}');
    }
  }

  /// Get the first page the user has access to
  Future<String?> _getFirstAccessiblePage() async {
    final url = Uri.parse('$_baseUrl/search');

    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'filter': <String, String>{'property': 'object', 'value': 'page'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      if (results.isNotEmpty) {
        return results.first['id'] as String;
      }
    }

    return null;
  }

  /// Get HTTP headers for Notion API requests
  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_apiToken',
      'Content-Type': 'application/json',
      'Notion-Version': _apiVersion,
    };
  }

  /// Convert a Notion page to a ProgressEntryModel
  ProgressEntryModel _pageToProgressEntry(Map<String, dynamic> page) {
    final properties = page['properties'] as Map<String, dynamic>;
    String? notes;

    if (properties.containsKey('Notes') &&
        properties['Notes']['rich_text'] is List) {
      final richText = properties['Notes']['rich_text'] as List<dynamic>;
      notes = richText.isEmpty
          ? ''
          : richText.map((item) => item['plain_text'] as String).join('');
    }

    String? dateStr;
    if (properties.containsKey('Date') && properties['Date']['date'] != null) {
      dateStr = properties['Date']['date']['start'] as String?;
    }

    bool morningDone = false;
    if (properties.containsKey('Morning Application')) {
      morningDone =
          properties['Morning Application']['checkbox'] as bool? ?? false;
    }

    bool eveningDone = false;
    if (properties.containsKey('Evening Application')) {
      eveningDone =
          properties['Evening Application']['checkbox'] as bool? ?? false;
    }

    String? photoUrl;
    if (properties.containsKey('Photo URL')) {
      photoUrl = properties['Photo URL']['url'] as String?;
    }

    return ProgressEntryModel(
      id: page['id'] as String,
      date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      morningApplicationDone: morningDone,
      eveningApplicationDone: eveningDone,
      notes: notes,
      photoPath: photoUrl,
    );
  }

  /// Create properties for a Notion page from a ProgressEntryModel
  Map<String, dynamic> _progressEntryToProperties(ProgressEntryModel entry) {
    // Format the date as a title for the entry
    final formattedDate = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
  
    return <String, dynamic>{
      // Add a title property (using the date as the title)
      'Name': <String, dynamic>{
        'type': 'title',
        'title': [
          <String, dynamic>{
            'type': 'text',
            'text': <String, dynamic>{
              'content': 'Entry: $formattedDate',
            },
          },
        ],
      },
      'Date': <String, dynamic>{
        'type': 'date',
        'date': <String, dynamic>{
          'start': entry.date.toIso8601String(),
        },
      },
      'Morning Application': <String, dynamic>{
        'type': 'checkbox',
        'checkbox': entry.morningApplicationDone,
      },
      'Evening Application': <String, dynamic>{
        'type': 'checkbox',
        'checkbox': entry.eveningApplicationDone,
      },
      'Notes': <String, dynamic>{
        'type': 'rich_text',
        'rich_text': [
          <String, dynamic>{
            'type': 'text',
            'text': <String, dynamic>{
              'content': entry.notes ?? '',
            },
          },
        ],
      },
      'Photo URL': <String, dynamic>{
        'type': 'url',
        'url': entry.photoPath ?? '',
      },
    };
  }

  @override
  Future<List<ProgressEntryModel>> getProgressEntries() async {
    final dbId = await _getDatabaseId();

    final url = Uri.parse('$_baseUrl/databases/$dbId/query');

    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'sorts': [
          <String, String>{
            'property': 'Date',
            'direction': 'descending',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      return results
          .map((page) => _pageToProgressEntry(page as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to get entries: ${response.body}');
    }
  }

  @override
  Future<ProgressEntryModel?> getProgressEntryByDate(DateTime date) async {
    final dbId = await _getDatabaseId();

    final targetDate = DateTime(date.year, date.month, date.day);
    final isoDate = targetDate.toIso8601String().split('T')[0];

    final url = Uri.parse('$_baseUrl/databases/$dbId/query');

    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'filter': <String, dynamic>{
          'property': 'Date',
          'date': <String, String>{
            'equals': isoDate,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      if (results.isEmpty) {
        return null;
      }

      return _pageToProgressEntry(results.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get entry by date: ${response.body}');
    }
  }

  @override
  Future<ProgressEntryModel> saveProgressEntry(ProgressEntryModel entry) async {
    final dbId = await _getDatabaseId();

    // Check if an entry already exists for this date
    final existingEntry = await getProgressEntryByDate(entry.date);
    if (existingEntry != null) {
      return updateProgressEntry(
        ProgressEntryModel(
          id: existingEntry.id,
          date: entry.date,
          morningApplicationDone: entry.morningApplicationDone,
          eveningApplicationDone: entry.eveningApplicationDone,
          notes: entry.notes,
          photoPath: entry.photoPath,
        ),
      );
    }

    // Create a new page in the database
    final properties = _progressEntryToProperties(entry);

    final url = Uri.parse('$_baseUrl/pages');

    final response = await _httpClient.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'parent': <String, dynamic>{
          'type': 'database_id',
          'database_id': dbId,
        },
        'properties': properties,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _pageToProgressEntry(data);
    } else {
      throw Exception('Failed to save entry: ${response.body}');
    }
  }

  @override
  Future<ProgressEntryModel> updateProgressEntry(
      ProgressEntryModel entry) async {
    final properties = _progressEntryToProperties(entry);

    final url = Uri.parse('$_baseUrl/pages/${entry.id}');

    final response = await _httpClient.patch(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'properties': properties,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _pageToProgressEntry(data);
    } else {
      throw Exception('Failed to update entry: ${response.body}');
    }
  }

  @override
  Future<String> saveProgressPhoto(String entryId, File photo) async {
    // Note: Notion API doesn't directly support file uploads
    // You would need to upload to another service like S3 and then store the URL
    // For this implementation, we'll store locally but update the Notion entry

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = '${entryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPhotoPath = '${photosDir.path}/$fileName';

    // Copy the photo to our app's storage
    await photo.copy(savedPhotoPath);

    // Get the entry from Notion
    final url = Uri.parse('$_baseUrl/pages/$entryId');
    final response = await _httpClient.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final pageData = jsonDecode(response.body) as Map<String, dynamic>;
      final entry = _pageToProgressEntry(pageData);

      // Update the entry with the new photo path
      final updatedEntry = ProgressEntryModel(
        id: entry.id,
        date: entry.date,
        morningApplicationDone: entry.morningApplicationDone,
        eveningApplicationDone: entry.eveningApplicationDone,
        notes: entry.notes,
        photoPath: savedPhotoPath,
      );

      await updateProgressEntry(updatedEntry);
      return savedPhotoPath;
    } else {
      throw Exception('Failed to get entry: ${response.body}');
    }
  }

  @override
  Future<bool> deleteProgressEntry(String entryId) async {
    final url = Uri.parse('$_baseUrl/pages/$entryId');

    final response = await _httpClient.patch(
      url,
      headers: _getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'archived': true,
      }),
    );

    return response.statusCode == 200;
  }

  @override
  Future<int> getCompletionRate() async {
    final entries = await getProgressEntries();
    if (entries.isEmpty) return 0;

    final completedEntries = entries
        .where((entry) =>
            entry.morningApplicationDone && entry.eveningApplicationDone)
        .length;

    return ((completedEntries / entries.length) * 100).round();
  }

  /// Utility method to check if the Notion integration is working
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/users/me');
      final response = await _httpClient.get(url, headers: _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

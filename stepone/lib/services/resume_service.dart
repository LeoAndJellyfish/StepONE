import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/achievement.dart';

class ResumeService {
  final String baseUrl;
  final String? apiKey;

  ResumeService({this.baseUrl = 'https://rxresu.me', this.apiKey});

  Future<Map<String, dynamic>> generateResumeData(
    String userName,
    String userEmail,
    List<Achievement> achievements,
  ) async {
    final sections = _categorizeAchievements(achievements);

    return {
      'basics': {'name': userName, 'email': userEmail},
      'sections': sections,
    };
  }

  Map<String, dynamic> _categorizeAchievements(List<Achievement> achievements) {
    final awards = <Map<String, dynamic>>[];
    final projects = <Map<String, dynamic>>[];
    final certificates = <Map<String, dynamic>>[];
    final publications = <Map<String, dynamic>>[];
    final volunteer = <Map<String, dynamic>>[];

    for (final achievement in achievements) {
      switch (achievement.categoryId) {
        case 1:
          awards.add({
            'title': achievement.title,
            'date': achievement.achievementDate.toIso8601String(),
            'award': achievement.remarks ?? '',
            'summary': achievement.description,
            'url': '',
          });
          break;
        case 3:
          projects.add({
            'name': achievement.title,
            'description': achievement.description,
            'date': achievement.achievementDate.toIso8601String(),
            'url': '',
          });
          break;
        case 5:
          certificates.add({
            'name': achievement.title,
            'date': achievement.achievementDate.toIso8601String(),
            'issuer': achievement.organization ?? '',
            'url': '',
          });
          break;
        case 4:
          publications.add({
            'name': achievement.title,
            'publisher': achievement.organization ?? '',
            'date': achievement.achievementDate.toIso8601String(),
            'url': '',
          });
          break;
        case 6:
          volunteer.add({
            'organization': achievement.organization ?? '',
            'position': achievement.title,
            'date': achievement.achievementDate.toIso8601String(),
            'summary': achievement.description,
            'url': '',
          });
          break;
      }
    }

    return {
      'awards': {'items': awards},
      'projects': {'items': projects},
      'certifications': {'items': certificates},
      'publications': {'items': publications},
      'volunteer': {'items': volunteer},
    };
  }

  Future<String?> exportToReactiveResume(
    Map<String, dynamic> resumeData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resume'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(resumeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      }

      return null;
    } catch (e) {
      print('Error exporting to Reactive Resume: $e');
      return null;
    }
  }

  Future<String> generateResumeJson(
    String userName,
    String userEmail,
    List<Achievement> achievements,
  ) async {
    final resumeData = await generateResumeData(
      userName,
      userEmail,
      achievements,
    );
    return const JsonEncoder.withIndent('  ').convert(resumeData);
  }
}

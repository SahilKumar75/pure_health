import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pure_health/ml/models/chat_model.dart';
import 'dart:convert';
import 'dart:io';

class Message {
  final String role;
  final String message;
  final String? intent;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.message,
    this.intent,
    this.metadata,
    required this.timestamp,
  });
}

class AIChatService {
  final Dio _dio;
  final String baseUrl;
  late List<Message> _messages;
  Map<String, dynamic>? _uploadedFileData;

  AIChatService({
    String baseUrl = 'http://172.20.10.4:8000',
  })  : baseUrl = baseUrl,
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            contentType: 'application/json',
          ),
        ) {
    _messages = [];
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🔍 API: $obj'),
      ),
    );
  }

  List<Message> get messages => _messages;

  Future<Map<String, dynamic>> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'pdf'],
      );

      if (result == null) {
        throw Exception('No file selected');
      }

      final file = result.files.first;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/api/files/analyze',
        data: formData,
      );

      if (response.statusCode == 200) {
        final fileContent = await _readFile(file.path!);
        _uploadedFileData = fileContent;

        return response.data;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Upload error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> _readFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      final lines = content.split('\n');
      final headers = lines[0].split(',');
      final data = <String, List<dynamic>>{};

      for (final header in headers) {
        data[header.trim()] = [];
      }

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].isEmpty) continue;
        final values = lines[i].split(',');

        for (int j = 0; j < headers.length; j++) {
          if (j < values.length) {
            final key = headers[j].trim();
            final value = values[j].trim();
            try {
              data[key]!.add(double.parse(value));
            } catch (_) {
              data[key]!.add(value);
            }
          }
        }
      }

      return data;
    } catch (e) {
      throw Exception('File read error: $e');
    }
  }

  Future<Message> sendMessage(String message) async {
    try {
      _messages.add(
        Message(
          role: 'user',
          message: message,
          timestamp: DateTime.now(),
        ),
      );

      final requestData = {
        'message': message,
        'file_data': _uploadedFileData,
      };

      final response = await _dio.post(
        '$baseUrl/api/chat/process',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        String aiResponse = '';
        try {
          aiResponse = data['response'] ?? 'No response';
        } catch (_) {
          aiResponse = 'No response';
        }

        final aiMessage = Message(
          role: 'assistant',
          message: aiResponse,
          intent: data['intent'],
          metadata: data['metadata'],
          timestamp: DateTime.now(),
        );

        _messages.add(aiMessage);
        return aiMessage;
      } else {
        throw Exception('Failed to get response');
      }
    } on DioException catch (e) {
      throw Exception('Chat error: ${e.message}');
    }
  }

  void clearHistory() {
    _messages.clear();
    _uploadedFileData = null;
  }

  Map<String, dynamic>? get uploadedFileData => _uploadedFileData;
}

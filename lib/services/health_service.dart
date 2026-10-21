// ============================================
// UPDATED health_service.dart
// ============================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Model classes for streaming data
class StreamingUpdate {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  StreamingUpdate({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory StreamingUpdate.fromJson(Map<String, dynamic> json) {
    return StreamingUpdate(
      type: json['type'] ?? 'unknown',
      data: json['data'] ?? {},
    );
  }

  @override
  String toString() => 'StreamingUpdate(type: $type, data: $data)';
}

class HealthQuestionResult {
  final String finalResponse;
  final List<StreamingUpdate> updates;
  final bool success;
  final String? error;

  HealthQuestionResult({
    required this.finalResponse,
    required this.updates,
    required this.success,
    this.error,
  });
}

class HealthQuestionService {
  static const String baseUrl = 'http://localhost:9000';

  // Main streaming function - OPTION 1 implementation
  Future<HealthQuestionResult> askHealthQuestionWithStreaming(
    String prompt, {
    Function(StreamingUpdate)? onUpdate,
    Duration timeout = const Duration(minutes: 20),
  }) async {
    final url = Uri.parse('$baseUrl/generate/health/answer/stream');
    final List<StreamingUpdate> updates = [];
    String finalResponse = '';
    String? error;
    bool success = false;

    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'prompt': prompt});

      final streamedResponse = await http.Client()
          .send(request)
          .timeout(timeout);

      if (streamedResponse.statusCode == 200) {
        final stream = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data: ')) {
            try {
              final jsonData = line.substring(6).trim();
              if (jsonData.isEmpty) continue;

              final data = jsonDecode(jsonData);
              final update = StreamingUpdate.fromJson(data);
              updates.add(update);

              // Handle different update types
              switch (update.type) {
                case 'update':
                  // Real-time progress update
                  onUpdate?.call(update);
                  break;

                case 'final':
                  // Final result received
                  finalResponse =
                      data['data']['result'] ??
                      data['data']['data']['result'] ??
                      'No response received';
                  success = true;
                  onUpdate?.call(update);
                  break;

                case 'error':
                  // Error occurred
                  error = data['data']['message'] ?? 'Unknown error occurred';
                  finalResponse = error!;
                  onUpdate?.call(update);
                  break;

                case 'heartbeat':
                  // Keep-alive signal, ignore
                  break;

                default:
                  // Other update types
                  onUpdate?.call(update);
              }
            } catch (e) {
              print('Error parsing streaming data: $e');
            }
          }
        }
      } else {
        error = 'Failed to get response: ${streamedResponse.statusCode}';
        finalResponse = error;
      }
    } catch (e) {
      error = 'Connection error: $e';
      finalResponse = error;
    }

    return HealthQuestionResult(
      finalResponse: finalResponse,
      updates: updates,
      success: success,
      error: error,
    );
  }

  // Fallback to non-streaming for compatibility
  Future<String> askHealthQuestionFallback(String prompt) async {
    final url = Uri.parse('$baseUrl/generate/health/answer');
    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(minutes: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['response'] ?? "No response received.";
      } else {
        return "Failed to get response: ${res.statusCode}";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }
}

// Create a global instance
final HealthQuestionService _healthService = HealthQuestionService();

// Export the main function for backward compatibility
Future<String> askHealthQuestion(String prompt) async {
  final result = await _healthService.askHealthQuestionWithStreaming(prompt);
  return result.finalResponse;
}

// Export the streaming function for advanced usage
Future<HealthQuestionResult> askHealthQuestionWithProgress(
  String prompt, {
  Function(StreamingUpdate)? onUpdate,
}) {
  return _healthService.askHealthQuestionWithStreaming(
    prompt,
    onUpdate: onUpdate,
  );
}

// ============================================
// UPDATED ChatPage - Enhanced Version
// ============================================

import 'package:flutter/material.dart';
import '../services/health_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  //String _response = '';
  bool _loading = false;
  String _currentProgress = '';
  List<String> _progressSteps = [];
  int _completedSteps = 0;

  // Chat messages for better UX
  List<ChatMessage> _messages = [];

  void sendPrompt() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;

    // Add user message to chat
    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _loading = true;
      _currentProgress = 'Starting your request...';
      _progressSteps.clear();
      _completedSteps = 0;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final result = await askHealthQuestionWithProgress(
        userMessage,
        onUpdate: (update) {
          setState(() {
            switch (update.type) {
              case 'update':
                final checkpoint = update.data['checkpoint'] ?? 'Processing';
                final stepData = update.data['data'] ?? {};

                _currentProgress = _getProgressMessage(checkpoint, stepData);

                // Add to progress steps if not already there
                if (!_progressSteps.contains(checkpoint)) {
                  _progressSteps.add(checkpoint);
                  _completedSteps = _progressSteps.length - 1;
                } else {
                  _completedSteps = _progressSteps.indexOf(checkpoint);
                }
                break;

              case 'final':
                _currentProgress = 'Complete! ✅';
                _completedSteps = _progressSteps.length;
                break;

              case 'error':
                _currentProgress = 'Error occurred ❌';
                break;
            }
          });
        },
      );

      // Add AI response to chat
      setState(() {
        _messages.add(
          ChatMessage(
            text: result.finalResponse,
            isUser: false,
            timestamp: DateTime.now(),
            wasSuccessful: result.success,
          ),
        );
        _loading = false;
        _currentProgress = '';
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I encountered an error: $e',
            isUser: false,
            timestamp: DateTime.now(),
            wasSuccessful: false,
          ),
        );
        _loading = false;
        _currentProgress = '';
      });
    }

    _scrollToBottom();
  }

  String _getProgressMessage(String checkpoint, Map<String, dynamic> data) {
    switch (checkpoint) {
      case 'workflow started':
        return '🚀 Starting analysis...';
      case 'analyzing intent':
        return '🧠 Understanding your question...';
      case 'intent classified':
        return '✅ Question classified';
      case 'generating response':
        return '💭 Thinking about your answer...';
      case 'calling tool':
        final toolName = data['tool_name'] ?? 'tool';
        return '🔧 Using $toolName...';
      case 'searching the internet':
        return '🔍 Searching for latest information...';
      case 'processing search results':
        return '📊 Analyzing search results...';
      case 'search completed':
        return '✅ Research complete';
      case 'aggregating results':
        return '🔄 Preparing your answer...';
      case 'final response ready':
        return '✨ Finalizing response...';
      default:
        return checkpoint;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Health AI"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _loading) {
                  // Progress indicator
                  return _buildProgressIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything about health...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => sendPrompt(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _loading ? null : sendPrompt,
                  mini: true,
                  child:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentProgress,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          if (_progressSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  _progressSteps.isEmpty
                      ? 0
                      : (_completedSteps + 1) / _progressSteps.length,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_completedSteps + 1} of ${_progressSteps.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? Colors.blue
                        : (message.wasSuccessful ?? true)
                        ? Colors.grey[200]
                        : Colors.red[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Helper class for chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool? wasSuccessful;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.wasSuccessful,
  });
}

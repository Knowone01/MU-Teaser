import 'package:flutter/material.dart';
import 'package:mu_teaser/utils/open_ai_api/open_ai_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailPage extends StatefulWidget {
  final String adCreativeBody;
  final String snapshotUrl;
  final String? startTime;
  final String? stopTime;

  const AdDetailPage({
    super.key,
    required this.adCreativeBody,
    required this.snapshotUrl,
    this.startTime,
    this.stopTime,
  });

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial AI greeting
    _messages.add({
      'type': 'ai',
      'content':
          'Hello! I\'m here to help you analyze this advertisement. Ask me anything about the ad content, marketing strategies, target audience, or any concerns you might have.',
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'type': 'user', 'content': message});
      _isLoading = true;
      _chatController.clear();
    });

    try {
      // Use the specialized ad analysis method
      final response = await GeminiService.analyzeAd(
        widget.adCreativeBody,
        message,
      );

      setState(() {
        _messages.add({'type': 'ai', 'content': response});
        _isLoading = false;
      });

      // Scroll to bottom
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        _messages.add({
          'type': 'error',
          'content': 'Unable to get AI response. Please try again.',
        });
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['type'] == 'user';
    final isError = message['type'] == 'error';
    final isAI = message['type'] == 'ai';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.deepPurple.withOpacity(0.2)
            : isError
            ? Colors.red.withOpacity(0.2)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isUser
              ? Colors.deepPurple
              : isError
              ? Colors.red
              : Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isUser
                ? 'You'
                : isError
                ? 'Error'
                : 'AI Assistant',
            style: TextStyle(
              color: isUser
                  ? Colors.deepPurple
                  : isError
                  ? Colors.red
                  : Colors.lightGreenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message['content'] ?? '',
            style: TextStyle(
              color: isError ? Colors.redAccent : Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String duration = 'N/A';
    if (widget.startTime != null && widget.stopTime != null) {
      duration = '${widget.startTime} → ${widget.stopTime}';
    } else if (widget.startTime != null) {
      duration = 'From ${widget.startTime}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ad Details & Analysis"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text(
                    'AI Assistant',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'This AI assistant is powered by Google Gemini and can help you analyze advertisements, understand marketing strategies, and identify potential concerns.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Ad Creative Section
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ad Creative:",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.adCreativeBody,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration Section
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ad Duration:",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Facebook Archive Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchURL(widget.snapshotUrl);
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text("Open in Facebook Archive"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chat Section
                  const Text(
                    "AI Advertisement Analysis:",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: _messages.isEmpty
                        ? const Center(
                            child: Text(
                              "Ask me anything about this ad...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12.0),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Input Section
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText:
                            "Ask about marketing strategy, target audience, concerns...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.deepPurple,
                          ),
                          onPressed: _sendMessage,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

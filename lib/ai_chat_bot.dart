import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/ai_functions.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key, required ScrollController scrollController});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

 Future<void> sendMessage(String message) async {
  setState(() {
    _messages.add({"role": "user", "content": message});
    _isLoading = true;
  });

  final reply = await generateContent(_messages.last.toString(), context);

  setState(() {
    _isLoading = false;
    _messages.add({"role": "30 years experience Time and Life management coach", "content": reply});
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        shape: const RoundedRectangleBorder(     
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('AI Assistant'),
                    content: Text('This is an AI assistant that can guide you to manage your time and life effectively. Ask me anything!'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MarkdownBody(
                      data: message['content'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Ask the assistant...'),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text;
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

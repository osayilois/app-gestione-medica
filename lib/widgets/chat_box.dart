// lib/widgets/chat_box.dart
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class ChatBox extends StatefulWidget {
  final String doctorName;
  const ChatBox({Key? key, required this.doctorName}) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final List<Map<String, String>> messages = [
    {'sender': 'bot', 'text': 'Hello! How can I help you?'},
  ];

  final options = [
    'When are you available?',
    'What documents do I need?',
    'How does the visit work?',
  ];

  void _handleUserMessage(String userMessage) {
    setState(() {
      messages.add({'sender': 'user', 'text': userMessage});
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        messages.add({'sender': 'bot', 'text': _getBotResponse(userMessage)});
      });
    });
  }

  String _getBotResponse(String message) {
    switch (message) {
      case 'When are you available?':
        return '${widget.doctorName} receives patients Monday, Wednesday and Friday from 9:00 AM to 5:00 PM.';
      case 'What documents do I need?':
        return 'Bring your health card and your ID card. If necessary, also bring your prescription documents and test results.';
      case 'How does the visit work?':
        return 'The visit takes about 30/40 minutes, and your symthoms will be discussed and/or your test/s results will be analysed.';
      default:
        return "Sorry, I didn't understand your question.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Text('Chat assistant', style: AppTextStyles.title2()),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isBot = msg['sender'] == 'bot';
                      return Align(
                        alignment:
                            isBot
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isBot
                                    ? Colors.grey.shade200
                                    : Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: AppTextStyles.body(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      options.map((option) {
                        return ElevatedButton(
                          onPressed: () => _handleUserMessage(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade300,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            option,
                            style: AppTextStyles.buttons(color: Colors.white),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage(String message) {
    setState(() {
      _messages.add({
        'message': "You: $message",
        'time': DateFormat('HH:mm').format(DateTime.now()),
      });
      _controller.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'message':
              "Administrator: Thanks for your message! We will get back to you soon.",
          'time': DateFormat('HH:mm').format(DateTime.now()),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        "Submit your problem here",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index]['message']!;
                        final time = _messages[index]['time']!;
                        final isUserMessage = message.startsWith("You:");

                        return Column(
                          crossAxisAlignment: isUserMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              margin: isUserMessage
                                  ? const EdgeInsets.fromLTRB(70, 2, 0, 2)
                                  : const EdgeInsets.fromLTRB(0, 2, 70, 2),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                borderRadius: isUserMessage
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      )
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                              ),
                              child: Text(
                                message.replaceAll("You:", "").trim(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isUserMessage ? 0 : 8,
                                2,
                                isUserMessage ? 8 : 0,
                                8,
                              ),
                              child: Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        contentPadding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onSubmitted: (message) {
                        if (message.trim().isNotEmpty) {
                          _sendMessage(message);
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  splashRadius: 20,
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 30,
                  onPressed: () {
                    String message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import'package:skin_food_scanner/models/dot.dart';
// ChatMessage model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatScreen extends StatefulWidget {
  final String? productName;
  final List<String>? ingredients;

  const AIChatScreen({
    super.key,
    this.productName,
    this.ingredients,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isTyping = false;

  final List<String> quickQuestions = [
    "Is this product good for sensitive skin?",
    "What are the potentially harmful ingredients?",
    "Can I use this product during pregnancy?",
    "Are there any comedogenic ingredients?",
    "What's the safety rating explanation?",
    "Any natural alternatives?",
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    if (widget.productName != null) {
      messages.add(ChatMessage(
        text: "Hi! I'm here to help you understand the ingredients in ${widget.productName}. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } else {
      messages.add(ChatMessage(
        text: "Hi! I'm your skincare ingredient assistant. Ask me anything about cosmetic ingredients, product safety, or skincare concerns!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _clearChat() {
    setState(() {
      messages.clear();
      _addWelcomeMessage();
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      isTyping = true;
    });

    _messageController.clear();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        messages.add(ChatMessage(
          text: "This is a sample AI response to: \"$text\"",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        isTyping = false;
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  Widget _buildQuickQuestions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Questions:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: quickQuestions.map((question) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(question),
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => _sendMessage(question),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: isDark ? Colors.white : Colors.black),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alignment = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isUser
        ? (isDark ? const Color(0xFF2962FF) : const Color(0xFF2962FF))
        : (isDark ? Colors.grey[800] : Colors.grey[200]);
    final textColor = message.isUser
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isUser ? 16 : 0),
              bottomRight: Radius.circular(message.isUser ? 0 : 16),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Dot(),
              SizedBox(width: 4),
              Dot(delay: Duration(milliseconds: 200)),
              SizedBox(width: 4),
              Dot(delay: Duration(milliseconds: 400)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Start asking your skincare questions!',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF2D3436),
              ),
            ),
            if (widget.productName != null)
              Text(
                widget.productName!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          // Quick Questions
          if (messages.length <= 2) _buildQuickQuestions(),
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }
}

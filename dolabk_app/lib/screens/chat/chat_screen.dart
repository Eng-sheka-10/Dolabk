// lib/screens/chat/chat_screen.dart
import 'package:dolabk_app/models/send_message_dto.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/di/service_locator.dart';
import '../../services/message_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/user_avatar.dart';
import '../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String? userId; // If provided, open specific conversation

  const ChatScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageService = getIt<MessageService>();

  bool _isLoading = true;
  List<dynamic> _conversations = [];
  String? _selectedUserId;
  List<dynamic> _messages = [];
  final _messageController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _selectedUserId = widget.userId;
      _loadConversation(widget.userId!);
    } else {
      _loadConversations();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final response = await _messageService.getConversations();
      if (response.success) {
        setState(() {
          _conversations = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadConversation(String userId) async {
    setState(() => _isLoading = true);

    try {
      final response = await _messageService.getConversation(int.parse(userId));
      if (response.success) {
        setState(() {
          _messages = response.data ?? [];
          _isLoading = false;
        });

        // Start auto-refresh
        _refreshTimer?.cancel();
        _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          _refreshConversation(userId);
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshConversation(String userId) async {
    try {
      final response = await _messageService.getConversation(int.parse(userId));
      if (response.success && mounted) {
        setState(() {
          _messages = response.data ?? [];
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUserId == null)
      return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _messageService.sendMessage(
        SendMessageDto(
          receiverId: int.parse(_selectedUserId!),
          content: messageText,
        ),
      );

      // Refresh conversation
      _loadConversation(_selectedUserId!);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Widget _buildConversationsList() {
    if (_conversations.isEmpty) {
      return const EmptyState(
        message: 'No conversations yet',
        icon: Icons.chat_bubble_outline,
      );
    }

    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return ListTile(
          leading: UserAvatar(
            imageUrl: conversation.user?.profilePictureUrl,
            name: conversation.user?.fullName,
            showOnlineIndicator: true,
            isOnline: conversation.user?.isOnline ?? false,
          ),
          title: Text(
            conversation.user?.fullName ?? 'User',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            conversation.lastMessage?.content ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                conversation.lastMessage?.createdAt ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            setState(() {
              _selectedUserId = conversation.user?.id;
            });
            _loadConversation(conversation.user!.id);
          },
        );
      },
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Messages
        Expanded(
          child: _messages.isEmpty
              ? const Center(child: Text('No messages yet'))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final isMe =
                        message.senderId ==
                        'currentUserId'; // TODO: Get actual user ID

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppTheme.primaryGreen
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.createdAt ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryGreen),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const LoadingIndicator(message: 'Loading messages...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUserId == null ? 'Messages' : 'Chat'),
        leading: _selectedUserId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedUserId = null;
                    _messages = [];
                  });
                  _refreshTimer?.cancel();
                  _loadConversations();
                },
              )
            : null,
      ),
      body: _selectedUserId == null
          ? _buildConversationsList()
          : _buildChatView(),
    );
  }
}

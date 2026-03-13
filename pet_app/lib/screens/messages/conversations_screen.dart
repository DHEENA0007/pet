/// Conversations Screen - list of all chats

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/auth_provider.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.milkyCream,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primaryWarmBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Assistant',
            onPressed: () => context.push('/chatbot'),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          if (chat.conversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chat.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 80, color: AppColors.textGrey.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No conversations yet',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Message a pet owner from the pet detail page',
                      style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chat.conversations.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 76, color: Colors.grey.shade200),
            itemBuilder: (context, i) {
              final c = chat.conversations[i];
              return _ConversationTile(conversation: c);
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final initials = conversation.otherUserName.isNotEmpty
        ? conversation.otherUserName
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    final timeStr = _formatTime(conversation.lastMessageTime);
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryWarmBrown.withOpacity(0.15),
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.primaryWarmBrown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        conversation.otherUserName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
          color: AppColors.accentDarkBrown,
        ),
      ),
      subtitle: Text(
        conversation.isLastMine
            ? 'You: ${conversation.lastMessage}'
            : conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread ? AppColors.accentDarkBrown : AppColors.textGrey,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 11,
              color: hasUnread ? AppColors.primaryWarmBrown : AppColors.textGrey,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryWarmBrown,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.push(
        '/chat/${conversation.otherUserId}',
        extra: conversation.otherUserName,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

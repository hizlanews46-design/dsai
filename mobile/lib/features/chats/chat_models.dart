import 'package:equatable/equatable.dart';

enum DeliveryStatus { sent, delivered, read }

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.title,
    required this.preview,
    required this.unread,
    required this.online,
  });

  final String id;
  final String title;
  final String preview;
  final int unread;
  final bool online;

  @override
  List<Object?> get props => [id, title, preview, unread, online];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.mine,
    required this.ciphertext,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final bool mine;
  final String ciphertext;
  final DeliveryStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, mine, ciphertext, status, createdAt];
}

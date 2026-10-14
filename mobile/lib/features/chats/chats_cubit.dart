import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/network/api_client.dart';
import 'chat_models.dart';

class ChatsState extends Equatable {
  const ChatsState({this.threads = const [], this.loading = false});

  final List<ChatThread> threads;
  final bool loading;

  @override
  List<Object?> get props => [threads, loading];
}

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({ApiClient? api})
      : _api = api ?? ApiClient(),
        super(const ChatsState());

  final ApiClient _api;

  Future<void> load() async {
    emit(const ChatsState(loading: true));
    try {
      final res = await _api.get('/api/messages');
      final items = (res['data'] as List).cast<Map>();
      final grouped = <String, ChatThread>{};
      for (final m in items) {
        final peer = m['senderId'] == m['receiverId'] ? m['receiverId'] : m['receiverId'];
        grouped[peer as String] = ChatThread(
          id: peer,
          title: peer.toString().substring(0, 8),
          preview: 'Encrypted message',
          unread: 0,
          online: false,
        );
      }
      emit(ChatsState(threads: grouped.values.toList()));
    } catch (_) {
      emit(const ChatsState(threads: []));
    }
  }
}

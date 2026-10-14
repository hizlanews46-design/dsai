import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../settings/connection_priority.dart';

class DialerContact extends Equatable {
  const DialerContact({required this.name, required this.phone});
  final String name;
  final String phone;
  @override
  List<Object?> get props => [name, phone];
}

class DialerState extends Equatable {
  const DialerState({
    this.digits = '',
    this.contacts = const [],
    this.promptSimFallback = false,
    this.error,
  });

  final String digits;
  final List<DialerContact> contacts;
  final bool promptSimFallback;
  final String? error;

  DialerState copyWith({
    String? digits,
    List<DialerContact>? contacts,
    bool? promptSimFallback,
    String? error,
    bool clearError = false,
  }) {
    return DialerState(
      digits: digits ?? this.digits,
      contacts: contacts ?? this.contacts,
      promptSimFallback: promptSimFallback ?? this.promptSimFallback,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [digits, contacts, promptSimFallback, error];
}

class DialerCubit extends Cubit<DialerState> {
  DialerCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const DialerState());

  final Connectivity _connectivity;

  void pushDigit(String d) {
    if (state.digits.length >= 18) return;
    emit(state.copyWith(digits: '${state.digits}$d', promptSimFallback: false, clearError: true));
  }

  void backspace() {
    if (state.digits.isEmpty) return;
    emit(state.copyWith(digits: state.digits.substring(0, state.digits.length - 1)));
  }

  void setNumber(String n) => emit(state.copyWith(digits: n, promptSimFallback: false));

  Future<void> loadContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) return;
    final raw = await FlutterContacts.getContacts(withProperties: true);
    final mapped = <DialerContact>[];
    for (final c in raw) {
      if (c.phones.isEmpty) continue;
      mapped.add(DialerContact(name: c.displayName, phone: c.phones.first.number));
    }
    emit(state.copyWith(contacts: mapped));
  }

  Future<void> placeCall(ConnectionPriority priority) async {
    final number = state.digits.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.length < 3) {
      emit(state.copyWith(error: 'invalid'));
      return;
    }
    final net = await _connectivity.checkConnectivity();
    final online = net.any((r) => r != ConnectivityResult.none);
    final forceSim = priority == ConnectionPriority.simOnly;
    final noInternetPath = !online || forceSim;
    if (noInternetPath && priority != ConnectionPriority.internetOnly) {
      emit(state.copyWith(promptSimFallback: true));
      return;
    }
    if (!online) {
      emit(state.copyWith(promptSimFallback: true));
      return;
    }
  }

  Future<void> confirmSimCall() async {
    final number = state.digits.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: number);
    emit(state.copyWith(promptSimFallback: false));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      emit(state.copyWith(error: 'dial_failed'));
    }
  }

  void dismissPrompt() => emit(state.copyWith(promptSimFallback: false));
}

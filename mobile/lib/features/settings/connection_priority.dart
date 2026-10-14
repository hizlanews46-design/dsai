enum ConnectionPriority { auto, internetOnly, meshOnly, simOnly }

enum VibratePattern { none, short, defaultPattern, long }

enum NotificationPriority { low, defaultPriority, high }

class SettingsSnapshot {
  const SettingsSnapshot({
    this.priority = ConnectionPriority.auto,
    this.appLockEnabled = false,
    this.dataSaver = false,
    this.batterySaver = false,
    this.ringtone = 'default',
    this.vibrate = VibratePattern.defaultPattern,
    this.notificationPriority = NotificationPriority.high,
    this.meshDiscoverySeconds = 8,
  });

  final ConnectionPriority priority;
  final bool appLockEnabled;
  final bool dataSaver;
  final bool batterySaver;
  final String ringtone;
  final VibratePattern vibrate;
  final NotificationPriority notificationPriority;
  final int meshDiscoverySeconds;

  SettingsSnapshot copyWith({
    ConnectionPriority? priority,
    bool? appLockEnabled,
    bool? dataSaver,
    bool? batterySaver,
    String? ringtone,
    VibratePattern? vibrate,
    NotificationPriority? notificationPriority,
    int? meshDiscoverySeconds,
  }) {
    return SettingsSnapshot(
      priority: priority ?? this.priority,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      dataSaver: dataSaver ?? this.dataSaver,
      batterySaver: batterySaver ?? this.batterySaver,
      ringtone: ringtone ?? this.ringtone,
      vibrate: vibrate ?? this.vibrate,
      notificationPriority: notificationPriority ?? this.notificationPriority,
      meshDiscoverySeconds: meshDiscoverySeconds ?? this.meshDiscoverySeconds,
    );
  }
}

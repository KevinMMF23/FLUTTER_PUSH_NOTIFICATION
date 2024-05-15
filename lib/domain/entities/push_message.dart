import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_push_notification_2024_1/domain/entities/push_message.dart';
import 'package:flutter_push_notification_2024_1/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationsStatusChanged);
    on<NotificationReceived>(_notificationsReceived);
    // verificar estado de las notificaciones
    _checkPermissionsFCM();

    //Listener para notificaciones en primer plano(Foreground)
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationsStatusChanged(
      NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(state.copywith(status: event.status));
    _getFCMToken();
  }

  void _notificationsReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(
        state.copywith(notifications: [event.message, ...state.notifications]));
    ;
  }

  void _handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;
    final PushMessage notification = mapperRemoteMessageToEntity(message);
    print(notification.toString());
    add(NotificationReceived(notification));
  }

  PushMessage mapperRemoteMessageToEntity(RemoteMessage message) {
    return PushMessage(
        messageId: _getMessageId(message),
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        sentDate: message.sentTime ?? DateTime.now(),
        data: message.data,
        imageUrl: _getImageUrl(message.notification!));
  }

  String _getMessageId(RemoteMessage message) =>
      message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '';

  String? _getImageUrl(RemoteNotification notification) => Platform.isAndroid
      ? notification.android?.imageUrl
      : notification.apple?.imageUrl;

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  }

  void _checkPermissionsFCM() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print(token);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageId(String pushMessageID) {
    final exit = state.notifications
        .any((element) => element.messageId == pushMessageID);
    if (!exit) return null;
    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageID);
  }
}

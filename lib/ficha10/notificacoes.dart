import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'servidor.dart';
import 'shapref.dart';

final StreamController<void> atualizadorNotificacoes =
    StreamController<void>.broadcast();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem em background recebida: ${message.messageId}');
  if (_deveAtualizar(message)) {
    final dataHora = await ShaPref().getUltimaAtualizacao();
    await Servidor().sincronizar(dataHora);
    print('Sincronização em background concluída.');
  }
}

bool _deveAtualizar(RemoteMessage message) {
  final titulo = message.notification?.title?.toLowerCase() ?? '';
  final corpo = message.notification?.body?.toLowerCase() ?? '';
  final dados = message.data;
  return titulo.contains('atualiza') ||
      corpo.contains('atualiza') ||
      dados['comando'] == 'atualizar' ||
      dados['tipo'] == 'atualiza' ||
      dados['acao'] == 'fetch_api';
}

class Notificacoes {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> inicializar() async {
    print('A inicializar notificações...');

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _firebaseMessaging.subscribeToTopic('produtos_atualizados');
    print('Subscrito ao tópico: todos');

    String? token = await _firebaseMessaging.getToken();
    print('FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Mensagem em foreground recebida: ${message.messageId}');
      if (_deveAtualizar(message)) {
        final dataHora = await ShaPref().getUltimaAtualizacao();
        await Servidor().sincronizar(dataHora);
        atualizadorNotificacoes.add(null);
        print('Sincronização silenciosa em foreground concluída.');
      }
    });

    print('Serviço de notificações inicializado.');
  }
}
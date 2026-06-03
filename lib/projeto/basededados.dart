import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


// =====================================================
// BASE DE DADOS — Mesa & Mesa
// Tabelas:
//   - utilizadores
//   - mesas
//   - pratos
//   - pedidos
//   - pedido_pratos
// =====================================================

class Basededados {
  static final Basededados _instance = Basededados._internal();
  static Database? _database;

  factory Basededados() {
    return _instance;
  }

  Basededados._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mesaemesa.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Se a versão mudar, apagamos tudo e recriamos (apenas para desenvolvimento)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS pedido_pratos');
    await db.execute('DROP TABLE IF EXISTS pedidos');
    await db.execute('DROP TABLE IF EXISTS pratos');
    await db.execute('DROP TABLE IF EXISTS mesas');
    await db.execute('DROP TABLE IF EXISTS utilizadores');
    await _onCreate(db, newVersion);
  }

  // =====================================================
  // CRIAÇÃO DAS TABELAS
  // =====================================================

  Future<void> _onCreate(Database db, int version) async {

    // Tabela utilizadores
    await db.execute('''
      CREATE TABLE utilizadores (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        nome     TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        perfil   TEXT NOT NULL,
        id_mesa  INTEGER,
        FOREIGN KEY (id_mesa) REFERENCES mesas (id)
      )
    ''');

    // Tabela mesas
    await db.execute('''
      CREATE TABLE mesas (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        numero INTEGER NOT NULL UNIQUE,
        estado TEXT NOT NULL
      )
    ''');

    // Tabela pratos
    await db.execute('''
      CREATE TABLE pratos (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nome      TEXT NOT NULL,
        descricao TEXT,
        preco     REAL NOT NULL,
        categoria TEXT NOT NULL,
        imagem    TEXT
      )
    ''');

    // Tabela pedidos
    await db.execute('''
      CREATE TABLE pedidos (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        id_mesa  INTEGER NOT NULL,
        estado   TEXT NOT NULL,
        data     TEXT NOT NULL,
        FOREIGN KEY (id_mesa) REFERENCES mesas (id)
      )
    ''');

    // Tabela pedido_pratos
    await db.execute('''
      CREATE TABLE pedido_pratos (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pedido  INTEGER NOT NULL,
        id_prato   INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id),
        FOREIGN KEY (id_prato)  REFERENCES pratos (id)
      )
    ''');

    // Inserir dados iniciais
    await _inserirDadosIniciais(db);
  }

  // =====================================================
  // DADOS INICIAIS
  // =====================================================

  Future<void> _inserirDadosIniciais(Database db) async {

    // Utilizadores de teste (Staff)
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['Administrador', 'admin', '1234', 'administrador'],
    );
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['João Silva', 'empregado', '1234', 'empregado'],
    );
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['Cozinha Principal', 'cozinha', '1234', 'cozinha'],
    );

    // Criar 10 mesas e os seus respetivos utilizadores (Clientes)
    for (int i = 1; i <= 10; i++) {
      // 1. Inserir a mesa
      int idMesa = await db.rawInsert(
        'INSERT INTO mesas(numero, estado) VALUES(?, ?)',
        [i, 'livre'],
      );

      // 2. Inserir o utilizador para essa mesa
      // Username: mesa1, mesa2... Password: 1234 (podes mudar para ser igual ao username)
      await db.rawInsert(
        'INSERT INTO utilizadores(nome, username, password, perfil, id_mesa) VALUES(?, ?, ?, ?, ?)',
        ['Mesa $i', 'mesa$i', '1234', 'cliente', idMesa],
      );
    }
  }

  // =====================================================
  // UTILIZADORES
  // =====================================================

  Future<List<Map<String, dynamic>>> listarUtilizadores() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM utilizadores');
  }

  Future<Map<String, dynamic>?> autenticar(String username, String password) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT * FROM utilizadores WHERE username = ? AND password = ?',
      [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> inserirUtilizador(String nome, String username, String password, String perfil, {int? idMesa}) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil, id_mesa) VALUES(?, ?, ?, ?, ?)',
      [nome, username, password, perfil, idMesa],
    );
  }

  Future<int> atualizarUtilizador(int id, String nome, String username, String password, String perfil, {int? idMesa}) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE utilizadores SET nome = ?, username = ?, password = ?, perfil = ?, id_mesa = ? WHERE id = ?',
      [nome, username, password, perfil, idMesa, id],
    );
  }

  Future<int> eliminarUtilizador(int id) async {
    final db = await database;
    return await db.rawDelete(
      'DELETE FROM utilizadores WHERE id = ?',
      [id],
    );
  }

  // =====================================================
  // MESAS
  // =====================================================

  Future<List<Map<String, dynamic>>> listarMesas() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM mesas ORDER BY numero');
  }

  Future<int> atualizarEstadoMesa(int id, String estado) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE mesas SET estado = ? WHERE id = ?',
      [estado, id],
    );
  }

  Future<int> inserirMesa(int numero) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO mesas(numero, estado) VALUES(?, ?)',
      [numero, 'livre'],
    );
  }

  Future<int> eliminarMesa(int id) async {
    final db = await database;
    return await db.rawDelete(
      'DELETE FROM mesas WHERE id = ?',
      [id],
    );
  }

  // =====================================================
  // PRATOS
  // =====================================================

  Future<List<Map<String, dynamic>>> listarPratos() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM pratos ORDER BY categoria');
  }

  Future<List<Map<String, dynamic>>> listarPratosPorCategoria(String categoria) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT * FROM pratos WHERE categoria = ?',
      [categoria],
    );
  }

  Future<int> inserirPrato(String nome, String descricao, double preco, String categoria, String imagem) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO pratos(nome, descricao, preco, categoria, imagem) VALUES(?, ?, ?, ?, ?)',
      [nome, descricao, preco, categoria, imagem],
    );
  }

  Future<int> atualizarPrato(int id, String nome, String descricao, double preco, String categoria, String imagem) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE pratos SET nome = ?, descricao = ?, preco = ?, categoria = ?, imagem = ? WHERE id = ?',
      [nome, descricao, preco, categoria, imagem, id],
    );
  }

  Future<int> eliminarPrato(int id) async {
    final db = await database;
    return await db.rawDelete(
      'DELETE FROM pratos WHERE id = ?',
      [id],
    );
  }

  // =====================================================
  // PEDIDOS
  // =====================================================

  Future<List<Map<String, dynamic>>> listarPedidos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT pedidos.*, mesas.numero as numero_mesa
      FROM pedidos
      JOIN mesas ON pedidos.id_mesa = mesas.id
      ORDER BY pedidos.id DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> listarPedidosPorEstado(String estado) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT pedidos.*, mesas.numero as numero_mesa
      FROM pedidos
      JOIN mesas ON pedidos.id_mesa = mesas.id
      WHERE pedidos.estado = ?
      ORDER BY pedidos.id DESC
    ''', [estado]);
  }

  Future<List<Map<String, dynamic>>> listarPedidosPorMesa(int idMesa) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT pedidos.*, mesas.numero as numero_mesa
      FROM pedidos
      JOIN mesas ON pedidos.id_mesa = mesas.id
      WHERE pedidos.id_mesa = ?
      ORDER BY pedidos.id DESC
    ''', [idMesa]);
  }

  Future<double> calcularTotalMesa(int idMesa) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(pratos.preco * pedido_pratos.quantidade) as total
      FROM pedidos
      JOIN pedido_pratos ON pedidos.id = pedido_pratos.id_pedido
      JOIN pratos ON pedido_pratos.id_prato = pratos.id
      WHERE pedidos.id_mesa = ?
    ''', [idMesa]);
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> inserirPedido(int idMesa, String estado, String data) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO pedidos(id_mesa, estado, data) VALUES(?, ?, ?)',
      [idMesa, estado, data],
    );
  }

  Future<int> atualizarEstadoPedido(int id, String estado) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE pedidos SET estado = ? WHERE id = ?',
      [estado, id],
    );
  }

  // =====================================================
  // PEDIDO_PRATOS
  // =====================================================

  Future<List<Map<String, dynamic>>> listarPratosDoPedido(int idPedido) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT pedido_pratos.*, pratos.nome, pratos.preco
      FROM pedido_pratos
      JOIN pratos ON pedido_pratos.id_prato = pratos.id
      WHERE pedido_pratos.id_pedido = ?
    ''', [idPedido]);
  }

  Future<int> inserirPratoPedido(int idPedido, int idPrato, int quantidade) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO pedido_pratos(id_pedido, id_prato, quantidade) VALUES(?, ?, ?)',
      [idPedido, idPrato, quantidade],
    );
  }

  // =====================================================
  // SINCRONIZAÇÃO FIRESTORE <-> SQLITE
  // =====================================================

  Future<void> sincronizarComFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('pedidos').get();
      final db = await database;
      
      final Set<String> activeOrderKeys = {}; // Formato: "idMesa_data"
      final Map<String, String> orderStates = {}; // Chave -> estado texto
      final List<Map<String, dynamic>> docList = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String? mesaStr = data['mesa'];
        final String? dataIso = data['data'];
        if (mesaStr != null && dataIso != null) {
          final key = "${mesaStr}_$dataIso";
          activeOrderKeys.add(key);
          docList.add(data);
          
          final int estadoInt = data['estado'] ?? 0;
          String estadoSql = 'pendente';
          if (estadoInt == 1) {
            estadoSql = 'preparacao';
          } else if (estadoInt == 2) {
            estadoSql = 'pronto';
          } else if (estadoInt == 3) {
            estadoSql = 'entregue';
          }
          
          orderStates[key] = estadoSql;
        }
      }

      await db.transaction((txn) async {
        // 1. Obter todos os pedidos locais
        final List<Map<String, dynamic>> localPedidos = await txn.rawQuery(
          'SELECT id, id_mesa, data, estado FROM pedidos'
        );
        
        // 2. Apagar localmente pedidos que já não existem no Firestore (porque foram faturados)
        for (final local in localPedidos) {
          final int localId = local['id'] as int;
          final int localMesa = local['id_mesa'] as int;
          final String localData = local['data'] as String;
          final key = "${localMesa}_$localData";
          
          if (!activeOrderKeys.contains(key)) {
            await txn.rawDelete('DELETE FROM pedido_pratos WHERE id_pedido = ?', [localId]);
            await txn.rawDelete('DELETE FROM pedidos WHERE id = ?', [localId]);
          }
        }
        
        // 3. Adicionar/Atualizar pedidos vindos do Firestore
        for (final data in docList) {
          final String? mesaStr = data['mesa'];
          final String? dataIso = data['data'];
          final String? produto = data['produto'];
          final int? quantidade = data['quantidade'];
          
          if (mesaStr == null || dataIso == null || produto == null || quantidade == null) continue;
          
          final int idMesa = int.tryParse(mesaStr) ?? 0;
          if (idMesa == 0) continue;
          
          final key = "${mesaStr}_$dataIso";
          final String estadoSql = orderStates[key] ?? 'pendente';
          
          // Encontrar ou criar o pedido local
          final List<Map<String, dynamic>> pedExist = await txn.rawQuery(
            'SELECT id, estado FROM pedidos WHERE id_mesa = ? AND data = ?',
            [idMesa, dataIso],
          );
          
          int idPedido;
          if (pedExist.isEmpty) {
            idPedido = await txn.rawInsert(
              'INSERT INTO pedidos(id_mesa, estado, data) VALUES(?, ?, ?)',
              [idMesa, estadoSql, dataIso],
            );
          } else {
            idPedido = pedExist.first['id'] as int;
            final String estadoAtual = pedExist.first['estado'] as String;
            if (estadoAtual != estadoSql) {
              await txn.rawUpdate(
                'UPDATE pedidos SET estado = ? WHERE id = ?',
                [estadoSql, idPedido],
              );
            }
          }
          
          // Encontrar ID do prato por nome
          final List<Map<String, dynamic>> pratos = await txn.rawQuery(
            'SELECT id FROM pratos WHERE nome = ?',
            [produto],
          );
          
          if (pratos.isNotEmpty) {
            final int idPrato = pratos.first['id'] as int;
            
            final List<Map<String, dynamic>> itemExist = await txn.rawQuery(
              'SELECT id FROM pedido_pratos WHERE id_pedido = ? AND id_prato = ?',
              [idPedido, idPrato],
            );
            
            if (itemExist.isEmpty) {
              await txn.rawInsert(
                'INSERT INTO pedido_pratos(id_pedido, id_prato, quantidade) VALUES(?, ?, ?)',
                [idPedido, idPrato, quantidade],
              );
            }
          }
        }
        
        // 4. Sincronizar estado das mesas com base nos pedidos ativos
        // Primeiro limpar o estado de todas as mesas para 'livre'
        await txn.rawUpdate("UPDATE mesas SET estado = 'livre'");
        
        // Depois marcar como 'ocupada' as mesas com pedidos ativos
        final List<Map<String, dynamic>> activeMesas = await txn.rawQuery(
          'SELECT DISTINCT id_mesa FROM pedidos'
        );
        for (final row in activeMesas) {
          final int idMesa = row['id_mesa'] as int;
          await txn.rawUpdate("UPDATE mesas SET estado = 'ocupada' WHERE id = ?", [idMesa]);
        }
      });
    } catch (e) {
      debugPrint('Erro ao sincronizar com Firestore: $e');
    }
  }

  Future<void> atualizarEstadoPedidoNoFirestore(int idPedido, String novoEstado) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> pedidos = await db.rawQuery(
        'SELECT id_mesa, data FROM pedidos WHERE id = ?',
        [idPedido],
      );
      
      if (pedidos.isEmpty) return;
      
      final int idMesa = pedidos.first['id_mesa'] as int;
      final String dataIso = pedidos.first['data'] as String;
      
      int estadoInt = 0;
      if (novoEstado == 'preparacao') {
        estadoInt = 1;
      } else if (novoEstado == 'pronto') {
        estadoInt = 2;
      } else if (novoEstado == 'entregue') {
        estadoInt = 3;
      }
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('mesa', isEqualTo: idMesa.toString())
          .where('data', isEqualTo: dataIso)
          .get();
          
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'estado': estadoInt});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao atualizar estado no Firestore: $e');
    }
  }

  Future<void> faturarMesaNoFirestore(int idMesa) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('mesa', isEqualTo: idMesa.toString())
          .get();
          
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao faturar mesa no Firestore: $e');
    }
  }
}
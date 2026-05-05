import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _onCreate,
    );
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
        perfil   TEXT NOT NULL
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

    // Utilizadores de teste
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['Administrador', 'admin', '1234', 'admin'],
    );
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['João Silva', 'empregado', '1234', 'empregado'],
    );
    await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      ['Cozinha Principal', 'cozinha', '1234', 'cozinha'],
    );

    // Mesas
    for (int i = 1; i <= 10; i++) {
      await db.rawInsert(
        'INSERT INTO mesas(numero, estado) VALUES(?, ?)',
        [i, 'livre'],
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

  Future<int> inserirUtilizador(String nome, String username, String password, String perfil) async {
    final db = await database;
    return await db.rawInsert(
      'INSERT INTO utilizadores(nome, username, password, perfil) VALUES(?, ?, ?, ?)',
      [nome, username, password, perfil],
    );
  }

  Future<int> atualizarUtilizador(int id, String nome, String username, String password, String perfil) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE utilizadores SET nome = ?, username = ?, password = ?, perfil = ? WHERE id = ?',
      [nome, username, password, perfil, id],
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
}
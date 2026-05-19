import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Basedados {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'antigravity.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            preco REAL NOT NULL,
            foto TEXT NOT NULL,
            data_atualizacao TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            email TEXT,
            telemovel TEXT,
            morada TEXT,
            data_atualizacao TEXT
          )
        ''');
      },
    );
  }

  // ── Produtos ──────────────────────────────────────────────

  Future<void> inserirOuAtualizarProduto(Map<String, dynamic> produto) async {
    final db = await database;
    await db.insert(
      'produtos',
      produto,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> listarProdutos() async {
    final db = await database;
    return await db.query('produtos');
  }

  Future<void> apagarProdutos() async {
    final db = await database;
    await db.delete('produtos');
  }

  /// Devolve o número de produtos existentes na base de dados local.
  Future<int> contarProdutos() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM produtos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── Clientes ──────────────────────────────────────────────

  Future<void> inserirOuAtualizarCliente(Map<String, dynamic> cliente) async {
    final db = await database;
    await db.insert(
      'clientes',
      cliente,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> listarClientes() async {
    final db = await database;
    return await db.query('clientes');
  }

  Future<void> apagarClientes() async {
    final db = await database;
    await db.delete('clientes');
  }

  /// Devolve o número de clientes existentes na base de dados local.
  Future<int> contarClientes() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM clientes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
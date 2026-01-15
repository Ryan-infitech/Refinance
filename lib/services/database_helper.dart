import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNullable = 'TEXT';

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        firebase_uid $textType UNIQUE,
        username $textType,
        email $textType UNIQUE,
        password $textType,
        created_at $textType
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        user_id INTEGER NOT NULL,
        type $textType,
        amount $realType,
        category $textType,
        description $textType,
        image_path $textTypeNullable,
        date $textType,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // User CRUD operations
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Transaction CRUD operations
  Future<int> createTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getTransactionsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByType(
      int userId, String type) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'date DESC',
    );

    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total income
  Future<double> getTotalIncome(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'income'],
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  // Get total expense
  Future<double> getTotalExpense(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'expense'],
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  // Get balance
  Future<double> getBalance(int userId) async {
    final income = await getTotalIncome(userId);
    final expense = await getTotalExpense(userId);
    return income - expense;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

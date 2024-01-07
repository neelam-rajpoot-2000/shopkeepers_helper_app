import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = 'shopkeeper_db.db';

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY,
        customerName TEXT,
        mobileNumber TEXT,
        service TEXT,
        totalPaidAmount REAL,
        partiallyPaidAmount REAL,
        type TEXT,
        imagePath TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertTransaction(
    String customerName,
    String mobileNumber,
    String service,
    double totalPaidAmount,
    double partiallyPaidAmount,
    String type,
    String? imagePath,
  ) async {
    final db = await _initDatabase();
    await db.insert(
      'transactions',
      {
        'customerName': customerName,
        'mobileNumber': mobileNumber,
        'service': service,
        'totalPaidAmount': totalPaidAmount,
        'partiallyPaidAmount': partiallyPaidAmount,
        'type': type,
        'imagePath': imagePath,
        'timestamp': DateTime.now().toString(),
      },
    );
  }
Future<List<Map<String, dynamic>>> fetchTransactions() async {
  final db = await _initDatabase();
  final List<Map<String, dynamic>> transactions = await db.query('transactions');
  return transactions;
}


Future<Map<String, dynamic>> fetchDashboardData() async {
  final db = await _initDatabase();
  final result = await db.rawQuery('''
    SELECT 
      SUM(CASE WHEN type = 'income' THEN totalPaidAmount ELSE 0 END) as totalIncome,
      SUM(CASE WHEN type = 'expense' THEN totalPaidAmount ELSE 0 END) as totalExpense,
      SUM(CASE WHEN type = 'income' AND partiallyPaidAmount > 0 THEN partiallyPaidAmount ELSE 0 END) as toBeReceived,
      SUM(CASE WHEN type = 'expense' AND partiallyPaidAmount > 0 THEN partiallyPaidAmount ELSE 0 END) as toBePaid
    FROM transactions
  ''');
  return {
    'totalIncome': result.isNotEmpty ? result.first['totalIncome'] ?? 0 : 0,
    'totalExpense': result.isNotEmpty ? result.first['totalExpense'] ?? 0 : 0,
    'toBeReceived': result.isNotEmpty ? result.first['toBeReceived'] ?? 0 : 0,
    'toBePaid': result.isNotEmpty ? result.first['toBePaid'] ?? 0 : 0,
  };
}
}

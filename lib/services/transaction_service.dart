import 'dart:io';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class TransactionService {
  static final TransactionService instance = TransactionService._init();
  
  TransactionService._init();

  // Create new transaction
  Future<Map<String, dynamic>> createTransaction({
    required int userId,
    required String type,
    required double amount,
    required String category,
    required String description,
    String? imagePath,
    required String date,
  }) async {
    try {
      final transaction = Transaction(
        userId: userId,
        type: type,
        amount: amount,
        category: category,
        description: description,
        imagePath: imagePath,
        date: date,
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await DatabaseHelper.instance.createTransaction(transaction);

      if (id > 0) {
        return {
          'success': true,
          'message': 'Transaksi berhasil ditambahkan',
          'transactionId': id,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal menambahkan transaksi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get all transactions for a user
  Future<List<Transaction>> getTransactions(int userId) async {
    try {
      return await DatabaseHelper.instance.getTransactionsByUser(userId);
    } catch (e) {
      print('Error getting transactions: ${e.toString()}');
      return [];
    }
  }

  // Get transactions by type (income or expense)
  Future<List<Transaction>> getTransactionsByType(
      int userId, String type) async {
    try {
      return await DatabaseHelper.instance
          .getTransactionsByType(userId, type);
    } catch (e) {
      print('Error getting transactions by type: ${e.toString()}');
      return [];
    }
  }

  // Update transaction
  Future<Map<String, dynamic>> updateTransaction({
    required int id,
    required int userId,
    required String type,
    required double amount,
    required String category,
    required String description,
    String? imagePath,
    required String date,
    required String createdAt,
    String? oldImagePath, // Path to old image if changed
  }) async {
    try {
      // Delete old image if it's being replaced with a new one
      if (oldImagePath != null && oldImagePath.isNotEmpty) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final transaction = Transaction(
        id: id,
        userId: userId,
        type: type,
        amount: amount,
        category: category,
        description: description,
        imagePath: imagePath,
        date: date,
        createdAt: createdAt,
      );

      final result =
          await DatabaseHelper.instance.updateTransaction(transaction);

      if (result > 0) {
        return {
          'success': true,
          'message': 'Transaksi berhasil diupdate',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengupdate transaksi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Delete transaction
  Future<Map<String, dynamic>> deleteTransaction(int id,
      {String? imagePath}) async {
    try {
      // Delete image file if exists
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final result = await DatabaseHelper.instance.deleteTransaction(id);

      if (result > 0) {
        return {
          'success': true,
          'message': 'Transaksi berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal menghapus transaksi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get financial summary
  Future<Map<String, double>> getFinancialSummary(int userId) async {
    try {
      final income = await DatabaseHelper.instance.getTotalIncome(userId);
      final expense = await DatabaseHelper.instance.getTotalExpense(userId);
      final balance = await DatabaseHelper.instance.getBalance(userId);

      return {
        'income': income,
        'expense': expense,
        'balance': balance,
      };
    } catch (e) {
      print('Error getting financial summary: ${e.toString()}');
      return {
        'income': 0.0,
        'expense': 0.0,
        'balance': 0.0,
      };
    }
  }
}

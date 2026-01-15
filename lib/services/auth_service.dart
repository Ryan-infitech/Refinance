import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  
  AuthService._init();

  // Register new user with Firebase
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Register with Firebase Auth
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Gagal membuat user Firebase',
        };
      }

      // Update display name di Firebase
      await firebaseUser.updateDisplayName(username);

      // Simpan ke local SQLite untuk offline data
      final user = User(
        firebaseUid: firebaseUser.uid,
        username: username,
        email: email,
        password: '', // Tidak perlu simpan password karena sudah di Firebase
        createdAt: DateTime.now().toIso8601String(),
      );

      final userId = await DatabaseHelper.instance.createUser(user);

      if (userId > 0) {
        // Save session
        await saveSession(userId, email, username, firebaseUser.uid);

        return {
          'success': true,
          'message': 'Registrasi berhasil',
          'userId': userId,
          'firebaseUid': firebaseUser.uid,
        };
      } else {
        // Rollback Firebase user if local DB fails
        await firebaseUser.delete();
        return {
          'success': false,
          'message': 'Gagal menyimpan data lokal',
        };
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Login user with Firebase
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login with Firebase Auth
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Gagal login ke Firebase',
        };
      }

      // Get or create user in local database
      User? localUser =
          await DatabaseHelper.instance.getUserByFirebaseUid(firebaseUser.uid);

      if (localUser == null) {
        // User belum ada di local DB, buat baru
        localUser = User(
          firebaseUid: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? email,
          password: '',
          createdAt: DateTime.now().toIso8601String(),
        );

        final userId = await DatabaseHelper.instance.createUser(localUser);
        localUser = localUser.copyWith(id: userId);
      }

      // Save login session
      await saveSession(
        localUser.id!,
        localUser.email,
        localUser.username,
        firebaseUser.uid,
      );

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': localUser,
        'firebaseUser': firebaseUser,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Save login session
  Future<void> saveSession(
    int userId,
    String email,
    String username,
    String firebaseUid,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('firebaseUid', firebaseUid);
    await prefs.setBool('isLoggedIn', true);
  }

  // Get current user ID from session
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Get current username from session
  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Get current Firebase UID from session
  Future<String?> getCurrentFirebaseUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebaseUid');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    // Cek juga Firebase auth state
    if (isLoggedIn) {
      final firebaseUser = _firebaseAuth.currentUser;
      return firebaseUser != null;
    }
    
    return false;
  }

  // Logout
  Future<void> logout() async {
    // Logout from Firebase
    await _firebaseAuth.signOut();
    
    // Clear local session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

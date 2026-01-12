import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'juno_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final JunoService _junoService = JunoService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In (or Sign Up if user doesn't exist)
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // 1. Try to Sign In
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) await _ensureUserProfile(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      // 2. If User Not Found (or similar error), try to Register
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
         try {
           UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
           if (cred.user != null) await _ensureUserProfile(cred.user!);
           return cred;
         } on FirebaseAuthException catch (createError) {
           // If creation fails because email already exists, it means the initial login failed due to WRONG PASSWORD
           if (createError.code == 'email-already-in-use') {
             throw "Incorrect password for this email.";
           }
           throw createError.message ?? "Registration failed.";
         }
      }
      throw e.message ?? "Authentication failed.";
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Full User Model
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _db.collection(AppConstants.usersCollection).doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Internal: Sync with Juno or create default profile
  Future<void> _ensureUserProfile(User user) async {
    final userDocRef = _db.collection(AppConstants.usersCollection).doc(user.uid);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      // 1. Try to get data from Juno ERP
      final junoData = await _junoService.fetchStudentProfile(user.email!);

      // 2. Construct User Model
      final newUser = UserModel(
        uid: user.uid,
        email: user.email!,
        name: junoData?['name'] ?? user.displayName ?? 'Unknown User',
        role: junoData?['role'] ?? AppConstants.roleStudent, // Default to student
        className: junoData?['class_name'], // e.g. "CSE-A"
        junoId: junoData?['juno_id'],
      );

      // 3. Save to Firestore
      await userDocRef.set(newUser.toMap());
    }
  }
}

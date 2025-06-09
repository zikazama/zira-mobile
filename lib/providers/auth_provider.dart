import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);
      await _fetchUserData(userCredential.user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      final userId = userCredential.user!.uid;
      
      final userData = UserModel(
        id: userId,
        email: email,
        name: name,
      );
      
      await _firebaseService.saveUserData(userId, userData.toMap());
      await _fetchUserData(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      final doc = await _firebaseService.getUserData(userId);
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>, userId);
        await _firebaseService.setupMessaging(userId);
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> updateRelationshipDate(DateTime date) async {
    if (_user == null) return false;
    
    try {
      await _firebaseService.updateRelationshipDate(_user!.id, date);
      _user = _user!.copyWith(relationshipDate: date);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> linkWithPartner(String partnerEmail) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // In a real app, you would send an invitation to the partner
      // and link accounts after they accept
      // This is a simplified version
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
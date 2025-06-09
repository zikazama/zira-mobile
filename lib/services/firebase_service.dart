import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Expose firestore for direct access
  FirebaseFirestore get firestore => _firestore;

  // Auth methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // Firestore methods
  Future<void> saveUserData(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<void> updateRelationshipDate(String userId, DateTime date) async {
    await _firestore.collection('users').doc(userId).update({
      'relationshipDate': date,
    });
  }

  // Calendar events
  Future<void> addCalendarEvent(String userId, Map<String, dynamic> eventData) async {
    await _firestore.collection('users').doc(userId).collection('events').add(eventData);
  }

  Future<QuerySnapshot> getCalendarEvents(String userId) async {
    return await _firestore.collection('users').doc(userId).collection('events').get();
  }

  // Todo list
  Future<void> addTodoItem(String userId, Map<String, dynamic> todoData) async {
    await _firestore.collection('users').doc(userId).collection('todos').add(todoData);
  }

  Future<void> updateTodoItem(String userId, String todoId, Map<String, dynamic> todoData) async {
    await _firestore.collection('users').doc(userId).collection('todos').doc(todoId).update(todoData);
  }

  Future<void> deleteTodoItem(String userId, String todoId) async {
    await _firestore.collection('users').doc(userId).collection('todos').doc(todoId).delete();
  }

  // Menstruation tracker
  Future<void> saveMenstruationData(String userId, Map<String, dynamic> menstruationData) async {
    await _firestore.collection('users').doc(userId).collection('menstruation').add(menstruationData);
  }
  
  Future<void> updateMenstruationData(String userId, String dataId, Map<String, dynamic> menstruationData) async {
    await _firestore.collection('users').doc(userId).collection('menstruation').doc(dataId).update(menstruationData);
  }

  Future<QuerySnapshot> getMenstruationData(String userId) async {
    return await _firestore.collection('users').doc(userId).collection('menstruation').orderBy('date', descending: true).get();
  }

  // Budget planner
  Future<void> saveBudgetGoal(String userId, Map<String, dynamic> budgetData) async {
    await _firestore.collection('users').doc(userId).collection('budget').add(budgetData);
  }

  Future<void> updateBudgetGoal(String userId, String budgetId, Map<String, dynamic> budgetData) async {
    await _firestore.collection('users').doc(userId).collection('budget').doc(budgetId).update(budgetData);
  }
  
  // Alarm methods
  Future<void> addAlarm(String userId, Map<String, dynamic> alarmData) async {
    await _firestore.collection('users').doc(userId).collection('alarms').add(alarmData);
  }
  
  Future<void> updateAlarm(String userId, String alarmId, Map<String, dynamic> alarmData) async {
    await _firestore.collection('users').doc(userId).collection('alarms').doc(alarmId).update(alarmData);
  }
  
  Future<void> deleteAlarm(String userId, String alarmId) async {
    await _firestore.collection('users').doc(userId).collection('alarms').doc(alarmId).delete();
  }

  // Storage methods
  Future<String> uploadImage(String userId, String path, dynamic file) async {
    Reference ref = _storage.ref().child('users/$userId/$path');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Messaging methods
  Future<void> setupMessaging(String userId) async {
    String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
    
    _messaging.onTokenRefresh.listen((newToken) {
      _firestore.collection('users').doc(userId).update({
        'fcmToken': newToken,
      });
    });
  }

  Future<void> sendNotificationToPartner(String partnerId, String title, String body) async {
    DocumentSnapshot partnerDoc = await _firestore.collection('users').doc(partnerId).get();
    if (partnerDoc.exists) {
      String? partnerToken = partnerDoc.get('fcmToken');
      if (partnerToken != null) {
        // In a real app, you would use a cloud function or server to send the notification
        // This is just a placeholder for the implementation
        await _firestore.collection('notifications').add({
          'token': partnerToken,
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
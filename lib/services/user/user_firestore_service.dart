import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class UserFirestoreService {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<User> getUser(String id) async {
    DocumentSnapshot snapshot = await _usersRef.doc(id).get();
    return User.fromSnapshot(snapshot);
  }

  Future<List<User>> getUsers() async {
    QuerySnapshot snapshots = await _usersRef.get();
    return snapshots.docs
        .map((snapshot) => User.fromSnapshot(snapshot))
        .toList();
  }

  Future<List<User>> getUsersFromIDs(List<String> ids) async {
    QuerySnapshot snapshots =
        await _usersRef.where(FieldPath.documentId, whereIn: ids).get();
    return snapshots.docs.map((snapshot) {
      return User.fromSnapshot(snapshot);
    }).toList();
  }

  Future createUser(User user) async {
    return _usersRef.doc(user.id).set(user.toJson());
  }

  Future updateUser(
    String id, {
    String email,
    String address,
    String displayName,
    String desc,
    String photoUrl,
    String photoHeaderUrl,
    num userRating,
    num ratingCount,
    String roles,
    num spending,
    num earning,
  }) async {
    Map<String, dynamic> data = Map();
    ({
      'email': email,
      'address': address,
      'displayName': displayName,
      'desc': desc,
      'photoUrl': photoUrl,
      'photoHeaderUrl': photoHeaderUrl,
      'userRating': userRating,
      'ratingCount': ratingCount,
      'roles': roles,
      'spending': spending,
      'earning': earning,
    }).forEach((key, value) {
      if (value != null) data[key] = value;
    });

    return _usersRef.doc(id).update(data);
  }

  Future deleteUser(String id) async {
    await _usersRef.doc(id).delete();
  }
}

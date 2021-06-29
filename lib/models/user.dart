import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id, email, address, displayName, desc, photoUrl, headerPhotoUrl, roles;
  num userRating;
  num ratingCount;
  num spending;
  num earning;

  User({
    this.id,
    this.email,
    this.address,
    this.displayName,
    this.desc,
    this.photoUrl,
    this.headerPhotoUrl,
    this.userRating,
    this.ratingCount,
    this.spending,
    this.earning,
    this.roles,
  });

  factory User.createNew(
          {String id,
          String email,
          String displayName,
          String address,
          String roles}) =>
      User(
        id: id,
        email: email,
        displayName: displayName,
        desc: '',
        address: address,
        roles: roles,
        photoUrl: '',
        headerPhotoUrl: '',
        userRating: 0.1,
        ratingCount: 0,
        spending: 0,
        earning: 0,
      );

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> json = snapshot.data();
    json['id'] = snapshot.id;
    return User.fromJson(json);
  }

  factory User.fromRawJson(String str) => User.fromJson(jsonDecode(str));

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        address: json['address'],
        displayName: json['displayName'],
        desc: json['desc'],
        photoUrl: json['photoUrl'],
        headerPhotoUrl: json['headerPhotoUrl'],
        userRating: json['userRating'],
        ratingCount: json['ratingCount'],
        roles: json['roles'],
        spending: json['spending'],
        earning: json['earning'],
      );

  String toRawJson() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'address': address,
        'displayName': displayName,
        'desc': desc,
        'photoUrl': photoUrl,
        'headerPhotoUrl': headerPhotoUrl,
        'userRating': userRating,
        'ratingCount': ratingCount,
        'roles': roles,
        'spending': spending,
        'earning': earning,
      };
}

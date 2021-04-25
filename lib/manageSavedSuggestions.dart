import 'dart:io';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'auth_repository.dart';

class ManageSavedSuggestions with ChangeNotifier {
  Set<WordPair> _saved = Set<WordPair>();
  AuthRepository? _authenticator;
  CollectionReference _users = FirebaseFirestore.instance.collection('users');
  String _avatar_url = 'https://png.pngtree.com/png-vector/20190221/ourmid/pngtree-female-user-vector-avatar-icon-png-image_691518.jpg';

  String get avatar_url => _avatar_url;

  Set<WordPair> get saved => _saved;

  CollectionReference get users => _users;

  void removeSuggestion(WordPair pair) {
    // local
    _saved.remove(pair);
    notifyListeners();
    // cloud
    if (_authenticator!.isAuthenticated) _removeCloudSuggestion(pair);
  }

  Future _removeCloudSuggestion(WordPair pair) async {
    await _users.doc(_authenticator!.user!.uid).update({
      'savedSuggestions': FieldValue.arrayRemove([
        {'First': pair.first.toString(), 'Second': pair.second.toString()}
      ])
    });
  }

  void addSuggestion(WordPair pair) {
    // local
    _saved.add(pair);
    notifyListeners();
    // cloud
    if (_authenticator!.isAuthenticated) _addCloudSuggestion(pair);
  }

  Future _addCloudSuggestion(WordPair pair) async {
    await _users.doc(_authenticator!.user!.uid).update({
      'savedSuggestions': FieldValue.arrayUnion([
        {'First': pair.first.toString(), 'Second': pair.second.toString()}
      ])
    });
  }

  bool contains(WordPair pair) {
    return _saved.contains(pair);
  }

  bool isEmpty() {
    return _saved.isEmpty;
  }

  void clearAtLogOut() {
    _saved.clear();
    notifyListeners();
  }

  void update(AuthRepository authenticator) async {
    _authenticator = authenticator;

    if (_authenticator!.isAuthenticated) {
      var document = await _users.doc(_authenticator!.user!.uid).get();
      if (!document.exists)
        await _users
            .doc(_authenticator!.user!.uid)
            .set({'savedSuggestions': []});

      await _users.doc(_authenticator!.user!.uid).update({
        'savedSuggestions': FieldValue.arrayUnion(List<dynamic>.from(
            _saved.map((pair) => {'First': pair.first, 'Second': pair.second})))
      });

      _saved = await pullSavedSuggestions();
      _avatar_url = await pullFileUrl();
    }
    notifyListeners();
  }

  Future<Set<WordPair>> pullSavedSuggestions() {
    return _users
        .doc(_authenticator!.user!.uid)
        .get()
        .then((document) => document.data())
        .then((savedSug) => savedSug == null
            ? Set<WordPair>()
            : Set<WordPair>.from(savedSug['savedSuggestions'].map(
                (element) => WordPair(element['First'], element['Second']))));
  }

  Future<void> uploadFile(String file_path) async {
    File file = File(file_path);
    await firebase_storage.FirebaseStorage.instance
        .ref("${_authenticator!.user!.uid}.png")
        .putFile(file);
    _avatar_url = await pullFileUrl();
    notifyListeners();
  }

  Future<String> pullFileUrl() async {
    var url;
    try {
      url = await firebase_storage.FirebaseStorage.instance
          .ref("${_authenticator!.user!.uid}.png").getDownloadURL();
    } on Exception catch (e) {
      url = await firebase_storage.FirebaseStorage.instance
          .ref("Anonymous/anonymous.jpg").getDownloadURL();
    }
    return url;
  }

}

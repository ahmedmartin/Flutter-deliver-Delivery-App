import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ra7al_delivery/sign_up.dart';
import 'package:provider/provider.dart';
import 'home.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  String uid;
  @override
  void initState() {
    // TODO: implement initState
    uid = FirebaseAuth.instance.currentUser.uid.toString();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: uid ==null? Sign_up():Home(),

    );
  }

}


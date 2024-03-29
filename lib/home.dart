import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/user_data.dart';

class HomePage extends StatefulWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final UserData user;
  HomePage({super.key,required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Welcome, ${widget.user.user.displayName}', 
                    softWrap:true, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
                ),
            ],
          ),
        ), 
    );
  }
}




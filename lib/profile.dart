import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/user_data.dart';
import 'create_store.dart';

class ProfilePage extends StatefulWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final UserData user;
  ProfilePage({super.key,required this.user});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String photo = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
  @override
  Widget build(BuildContext context) {
    if (widget.user.user.photoURL != null) {
      photo = widget.user.user.photoURL.toString();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.all(6.0)),
                      CircleAvatar( 
                        radius: 27, // Image radius 
                        backgroundImage: NetworkImage(photo), 
                      ),
                      const Padding(padding: EdgeInsets.all(6.0)),
                      Text(
                        '${widget.user.user.displayName}', 
                        softWrap:true, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
                    ],
                  ),
                ),
                ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateStorePage(user: widget.user),
                    ),
                  );
                },
                child: const Text('Add Store'),
              ),
            ],
          ),
        ), 
    );
  }
}




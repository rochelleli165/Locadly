import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_new_user.dart';
import 'models/user_data.dart';

class LoginPage extends StatelessWidget {
  final db = FirebaseFirestore.instance;
  Future<User?> _signIn(BuildContext context, String type, String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      if(type == 'Google') {
        final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          final UserCredential authResult = await auth.signInWithCredential(credential);
          final User? user = authResult.user;
          if (user != null) {
            final docRef = db.collection("users").doc("${user.uid}");
            docRef.get().then(
              (DocumentSnapshot doc) {
                final data = doc.data() as Map<String,dynamic>?;
                if (data == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateNewUserPage(user: user),
                    ),
                  );
                }
                else {
                  UserData userData = UserData(user, data['location'], data['role'], data['first'], data['last']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(user: userData),
                    ),
                  );
                }
              },
              onError: (e) => print("Error getting document: $e"),
            );
            
          }
          return user;
        } 
      }
      else if(type == 'Sign Up') {
        final FirebaseAuth auth = FirebaseAuth.instance;
        try {
          final UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
          final User? user = userCredential.user;
          if(user != null) {
            print('User logged in: ${user.uid}');
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewUserPage(user: user),
            ),
            );
          }
        } catch (e) {
          if(e is PlatformException) {
            if(e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              print('email already in use');
            }
          }
          print('Sign Up: Failed to sign in with email and password: $e');
          // Handle login failure
        }
      }
      else if(type == "Login") {
        final FirebaseAuth auth = FirebaseAuth.instance;
        try {
          final UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final User? user = userCredential.user;
          if (user != null) {
            final docRef = db.collection("users").doc("${user.uid}");
            docRef.get().then(
              (DocumentSnapshot doc) {
                final data = doc.data() as Map<String,dynamic>?;
                if (data == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateNewUserPage(user: user),
                    ),
                  );
                }
                else {
                  UserData userData = UserData(user, data['location'], data['role'], data['first'], data['last']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(user: userData),
                    ),
                  );
                }
              },
              onError: (e) => print("Error getting document: $e"),
            );
          }
        } catch (e) {
          print('Login: Failed to sign in with email and password: $e');
          // Handle login failure
        }
      }
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<void> _loginBuilder(BuildContext context, String type) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: type == 'Login' ? const Text('Login') : const Text('Sign Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
              controller: password,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: type == 'Login' ? const Text('Login') : const Text('Sign Up'),
              onPressed: () {
                type == 'Login' ? _signIn(context, 'Login', email.text, password.text) : _signIn(context, 'Sign Up', email.text, password.text);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              Text('Locadly', style: TextStyle(fontSize: 30)),
              Padding(
                  padding: EdgeInsets.all(16.0),
              ),
              ElevatedButton(
                onPressed: ()  => _loginBuilder(context, 'Login'),
                child: const Text('Login'),
              ),
              Text('Not a member?'),
              ElevatedButton(
                onPressed: ()  => _loginBuilder(context, 'Sign Up'),
                child: const Text('Sign up'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _signIn(context, 'Google', '', '');
                },
                child: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



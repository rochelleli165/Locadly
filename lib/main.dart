import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'login.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)  => MyAppState(),
      child: MaterialApp(
          title: 'Square Hackathon Submission',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: LoginPage(),
        ),
    );
  }
}

class FirebaseService {
  Future<dynamic> fetchUser(email) async {
    Completer<dynamic> completer = Completer<dynamic>();
    String? username;
    int? atIndex =email.indexOf('@');
    if (atIndex != -1) {
      username = email.substring(0, atIndex); // Returns the part before the "@" symbol
    }
    final ud = FirebaseDatabase.instance.ref('users/$username');
    ud.onValue.listen((DatabaseEvent event){
      final u = event.snapshot.value;
      if (!completer.isCompleted) {
        completer.complete(u);
      }
    }); 
    return completer.future;
  }

  Future<dynamic> fetchQuests(location) async {
    Completer<dynamic> completer = Completer<dynamic>();
    final qd = FirebaseDatabase.instance.ref('quests').orderByChild('location/city').equalTo(location);
    qd.onValue.listen((DatabaseEvent event){
      final q = event.snapshot.value;
      completer.complete(q);
    }); 
    return await completer.future;
  }
}

class MyAppState extends ChangeNotifier {
  int currQuest = 0;
  var location = "No Location";
  String username = "No Username";
  dynamic _userInfo;
  dynamic _quests;

  dynamic get userInfo => _userInfo;
  dynamic get quests => _quests;

  Future<void> fetchQuests(location) async {
   final q = await FirebaseService().fetchQuests(location);
   _quests = q;
  }

  Future<void> fetchUser(email) async {
    final u = await FirebaseService().fetchUser(email);
     _userInfo = u;
    location = _userInfo['location']['city'];
    currQuest = _userInfo['current-quest'];
  }

  Future<int> fetchData(email) async {
    initUsername(email);
    await fetchUser(email);
    await fetchQuests(location);
    notifyListeners();
    return 0;
  }
  
  Future<void> setCurrent(c) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$username");   
    await ref.update({
      "current-quest": c,
    });
    currQuest = c;
    notifyListeners();
  }

  void acceptQuest(q) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("quests/$q/status");
    await ref.update({
      "user": username,
    });
    notifyListeners();
  }

  void initUsername(u) {
    int atIndex = u.indexOf('@');
    if (atIndex != -1) {
      username = u.substring(0, atIndex); // Returns the part before the "@" symbol
    }
  }
}





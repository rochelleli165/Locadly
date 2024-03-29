import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:locadly/models/autocomplate_prediction.dart';
import 'models/user_data.dart';
import 'navigation.dart';
import 'location_list_title.dart';
import 'network_utility.dart';
import 'models/place_auto_complete_response.dart';

const List<Widget> roles = <Widget>[
  Text('Buyer'),
  Text('Seller'),
];

const sRoles = ['Buyer', 'Seller'];

class CreateNewUserPage extends StatefulWidget {
  final User user;
  const CreateNewUserPage({super.key,required this.user});
  @override
  State<CreateNewUserPage> createState() => _CreateNewUserPageState();
}

class _CreateNewUserPageState extends State<CreateNewUserPage> {
  final List<bool> _selectedRoles = <bool> [false, false];
  var db = FirebaseFirestore.instance;

  final kGoogleApiKey = "AIzaSyCVIRfuPzfNQSOVDeOq_1KbxJInP_52ZRE";
  List<AutocompletePrediction> placePredictions = [];

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController location = TextEditingController();

  void placeAutocomplete(String query) async {
    Uri uri = Uri.https("maps.googleapis.com",
    "/maps/api/place/autocomplete/json",
    {
      'input': query,
      'key': kGoogleApiKey,
    });
    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      PlaceAutocompleteResponse result = 
      PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  Future<UserData?> _signIn(BuildContext context, String location, String firstName, String lastName) async {
    try {
        try {
            await widget.user.updateDisplayName("$firstName $lastName");
            String role = '';
            for(int i = 0; i < _selectedRoles.length; i++) {
              if (_selectedRoles[i]) {
                role = sRoles[i];
              }
            }
            final userD = <String, dynamic> {
              "first": firstName,
              "last": lastName,
              "location": location,
              "email": widget.user.email,
              "role" : role,
            };
            UserData userData = UserData(widget.user, location, role, firstName, lastName);
            db.collection("users").doc(widget.user.uid).set(userD).then((_) =>
              debugPrint('DocumentSnapshot added with ID: ${widget.user.uid}'));
            Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(user: userData),
                      ),
            );
        } catch (e) {
          if(e is PlatformException) {
            if(e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              debugPrint('email already in use');
            }
          }
          debugPrint('Sign Up: Failed to sign in with email and password: $e');
          // Handle login failure
        }
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New User'),
        ),
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: firstName,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastName,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const Text('Select Role in App'),
                  const SizedBox(height: 5),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _selectedRoles.length; i++) {
                          _selectedRoles[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Colors.red[700],
                    selectedColor: Colors.white,
                    fillColor: Colors.red[200],
                    color: Colors.red[400],
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _selectedRoles,
                    children: roles,
                  ),
                  TextFormField( 
                    controller: location,
                    decoration: const InputDecoration(
                      hintText: 'Location',
                    ),
                    onChanged: (value) {
                      placeAutocomplete(value);
                    },
                    textInputAction: TextInputAction.search,
                    
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: placePredictions.length,
                      itemBuilder: (context, index) =>
                      LocationListTile(
                        press: () {
                          setState(() {
                            location.text = placePredictions[index].description!;
                          });
                        },
                        location: placePredictions[index].description!,
                      ), 
                    ),
                  ),
                  ElevatedButton(onPressed: () { 
                    _signIn(context, location.text, firstName.text, lastName.text);                     
                  }, child: const Text('Submit')),
                ],
              ),
            ),
        ), 
    );
  }
}




import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/user_data.dart';
import 'profile.dart';
import 'package:flutter/services.dart';
import 'models/place_auto_complete_response.dart';
import 'models/autocomplate_prediction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'network_utility.dart';
import 'location_list_title.dart';
import 'models/store_data.dart';

class CreateStorePage extends StatefulWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final UserData user;
  CreateStorePage({super.key,required this.user});
  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final List<bool> _selectedRoles = <bool> [false, false];
  var db = FirebaseFirestore.instance;

  final kGoogleApiKey = "AIzaSyCVIRfuPzfNQSOVDeOq_1KbxJInP_52ZRE";
  List<AutocompletePrediction> placePredictions = [];
  final tags = ["Clothing", "Sports", "Cute", "Animal", "Grocery", "Thrift", "Hair, Nail, and Personal", "Cheap"];
  List<bool> tagsBool = List<bool>.filled(8, false);
  TextEditingController storeName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController  description = TextEditingController();

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

  Future<void> _createStore(BuildContext context, String storeName, String address, String description) async {
    try {        
        final storeD = <String, dynamic> {
          "name": storeName,
          "address": address,
          "description": description,
          "picture": null,
          "tags" : null,
          "owner": widget.user.user.uid,
        };
        StoreData storeData = StoreData(storeName, address, description, null, null, widget.user.user.uid);
        db.collection("stores").add(storeD).then((_) =>
          debugPrint('DocumentSnapshot added with ID: ${widget.user.user.uid}'));
        Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user),
                  ),
        );
    } catch (e) {
      debugPrint('Create store: Failed to create store: $e');
      // Handle login failure
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Store'),
        ),
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: storeName,
                    decoration: const InputDecoration(
                      hintText: 'Store Name',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField( 
                    controller: address,
                    decoration: const InputDecoration(
                      hintText: 'Address',
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
                            address.text = placePredictions[index].description!;
                          });
                        },
                        location: placePredictions[index].description!,
                      ), 
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(2.0)),
                  Text('Select tags for your shop'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tags.length,
                      itemBuilder: (context, index) =>
                      CheckboxListTile(
                        value: tagsBool[index],
                        onChanged: (bool? value) {
                          setState(() {
                            tagsBool[index] = value!;
                          });
                        },
                        title: Text(tags[index]),
                      ), 
                    ),
                  ),
                  ElevatedButton(onPressed: () { 
                    _createStore(context, storeName.text, address.text, description.text);                     
                  }, child: const Text('Submit')),
                ],
              ),
            ),
        ), 
    );
  }
}








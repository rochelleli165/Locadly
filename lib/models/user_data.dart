import 'package:firebase_auth/firebase_auth.dart';
class UserData {
  String? firstName;
  String? lastName;
  String location;
  String Role;
  User user;
  
  UserData(this.user, this.location, this.Role, this.firstName, this.lastName);

  String? get first {
    return firstName;
  }
  String? get last {
    return lastName;
  }
  String? get loc{
    return location;
  }
  String? get role {
    return Role;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future signup(name, number, address, email, [validIDUrl]) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'number': number,
    'address': address,
    'email': email,
    'id': docUser.id,
    'history': [],
    'bookmarks': [],
    'location': {'lat': 0.00, 'long': 0.00},
    'favorites': [],
    'notif': [],
    'profilePicture': 'https://cdn-icons-png.flaticon.com/256/149/149071.png',
    'deliveryHistory': [],
    'discount': 0,
    'validIDUrl': validIDUrl ?? '',
    'isVerified': validIDUrl != null ? true : false
  };

  await docUser.set(json);
}

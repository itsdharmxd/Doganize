
import 'package:cloud_firestore/cloud_firestore.dart';


 class DatabaseService {
  final String uid;
  DatabaseService({this.uid}) : super();
   final CollectionReference brewCollection =
       FirebaseFirestore.instance.collection('userData');

  Future updateUserData(String data ) async {
    return await brewCollection
        .doc(uid)
        .set({ "data":data  });
  }
   Future<DocumentSnapshot> getUserData( ) async {
    return await brewCollection
        .doc(uid).get() ;
  }

//   //brew list from snapshot
//   List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs.map((doc) {
//       return Brew(
//         name: doc.data()['name'] ?? '',
//         strength: doc.data()['strength'] ?? 0,
//         sugars: doc.data()['sugars'] ?? '',
//       );
//     }).toList();
//   }

//   ///userdata from snapshot
//   UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
//     return UserData(
//       uid: uid,
//       name: snapshot.data()['name'],
//       sugars: snapshot.data()['sugars'],
//       strength: snapshot.data()['strength'],
//     );
//   }

//   //get brews stream

//   Stream<List<Brew>> get brews {
//     return brewCollection.snapshots().map(_brewListFromSnapshot);
//   }

  //get user doc stream
  Stream<DocumentSnapshot> get userData {
    return brewCollection.doc(uid).snapshots() ;
  }
 }

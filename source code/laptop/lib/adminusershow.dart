import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyAe0Dwq_t1VQU4eyN-rDvw0HFuh1QCoRqM',
    appId: '1:488143009464:android:45c5385f1bdeb5abe8264d',
    messagingSenderId: '488143009464',
    projectId: 'fluttercli-d9ce0',
    storageBucket: 'fluttercli-d9ce0.appspot.com',
  ));
  runApp(Mylistt());
}

class Mylistt extends StatelessWidget {
  const Mylistt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomeUser(),
    );
  }
}

class MyHomeUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('User').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            final userData = documents[index].data() as Map<String, dynamic>;
            final String userId = documents[index].id;
            final String userName = userData['UserName'];
            final String userEmail = userData['UserEmail'];
            final String userNumber = userData['UserNumber'];
            final String imageURL = userData['imageURL'];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageURL),
              ),
              title: Text(userName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userEmail),
                  Text(userNumber),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Delete user
                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(userId)
                      .delete();
                },
              ),
            );
          },
        );
      },
    );
  }
}

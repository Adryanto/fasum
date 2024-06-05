import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fasum/screens/detail_screen.dart';
import 'package:fasum/screens/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fasum/screens/sign_in_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('test').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading....');
              default:
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        margin: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(
                            'Deskripsi : ${documentSnapshot['deskripsi']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              documentSnapshot['image_url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat.yMMMd().add_jm().format(
                                    documentSnapshot['timestamp'].toDate(),),style: TextStyle(fontSize: 18),
                                  ),
                              Text(
                                'Aktor: ${_auth.currentUser?.email == documentSnapshot['user_email'] ? _auth.currentUser?.email ?? 'Unknown' : documentSnapshot['user_email']}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      );
                  },
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PostScreen()));
        },
        label: Row(
          children: [
            Text(
              'Add',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            Icon(Icons.add, size: 30), // adjust the size to your liking
          ],
        ),
      ),
    );
  }
}

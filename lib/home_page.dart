import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _todoController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

 void _addTodo() {
  final user = _auth.currentUser;
  if (user != null && _todoController.text.isNotEmpty) {
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('list_tugas')
        .add({
          'tugas': _todoController.text,
          'isDone': false, // ✅ WAJIB
          'createdAt': Timestamp.now(), // (sekalian dirapikan)
        });
    _todoController.clear();
  }
}


  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            onPressed: () => _auth.signOut(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // listview todo list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user?.uid)
                  .collection('list_tugas')
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final bool isChecked = doc['isDone'] ?? false;

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            doc.reference.update({
                              'isDone': value,
                            });
                          },
                        ),
                        title: Text(
                          doc['tugas'],
                          style: TextStyle(
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () => doc.reference.delete(),
                          icon: Icon(Icons.delete),
                        ),
                      ),
                    );
                  },
                );

              },
            ),
          ),

          // row (textfield dan iconbutton)
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(hintText: 'Masukan Tugas'),
                  ),
                ),

                IconButton(onPressed: _addTodo, icon: Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

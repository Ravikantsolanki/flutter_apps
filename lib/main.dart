import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/contains/add_name.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context){
            return Anothername();
          }));
        },
        child: Icon(Icons.add),
        tooltip: 'Add one more item',
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),

    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          subtitle:Text(record.votes.toString()) ,

          onTap: () => Firestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(record.reference);
            final fresh = Record.fromSnapshot(freshSnapshot);
            await transaction
                .update(record.reference, {'votes': fresh.votes + 1});
          }),

          trailing: GestureDetector(
            child: Icon(Icons.delete, color: Colors.indigoAccent,),
            onTap:() {
              _AlertDialoge(context,data);
            }
          ),
        ),
      ),
    );
  }

  void _AlertDialoge(BuildContext context,DocumentSnapshot data){

    var alert = AlertDialog(
      title: Text('Are you sure?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: (){
            Navigator.pop(context);
            _deleteData(context, data);
          },
        ),

        FlatButton(
          child: Text('cancel'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ],
      //content:
      /* Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: <Widget>[
          RaisedButton(
            child: Text('Ok'),
            onPressed: (){
              flag=true;
              print("inside ok");
            },
          ),

          RaisedButton(
            child: Text('cancel'),
            onPressed: (){
              flag=false;
              print("inside cancel");
            },
          ),
        ],
      ),*/
    );

    showDialog(context: context,builder: (BuildContext context) => alert);
  }
}

void _deleteData(BuildContext context, DocumentSnapshot data){
  final record = Record.fromSnapshot(data);
  Firestore.instance.runTransaction((transaction) async {
    try {
      final freshSnapshot = await transaction.get(
          record.reference);
      final DocumentSnapshot ds = await transaction.get(
          Firestore.instance.collection('baby').document(
              freshSnapshot.documentID));

      await transaction.delete(ds.reference);
    } catch (error) {
      print('error:$error');
    }


  }

  );
  //Firestore.instance.collection('baby').document(Firestore.i).
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Anothername extends StatefulWidget {
  State<StatefulWidget> createState() => Addname();
}

class Addname extends State<Anothername> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _BuildName(context),
    );
  }
}

Widget _BuildName(BuildContext context) {
  final TextEditingController namecontroller = TextEditingController();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      children: <Widget>[
        TextField(
          controller: namecontroller,
          decoration: InputDecoration.collapsed(
              filled: true, hintText: "Add a new name"),
        ),
        SizedBox(height: 20.0),
        ButtonBar(
          children: <Widget>[
            RaisedButton(
              child: Text('Add'),
              onPressed: () {
                var document = Firestore.instance.collection('baby').document();
                var map = new Map<String, dynamic>();
                map['name'] = namecontroller.text;
                map['votes'] = 0;
                namecontroller.clear();
                document.setData(map);
              },
            ),
            RaisedButton(
              child: Text('Clear'),
              onPressed: () {
                namecontroller.clear();
              },
            ),
          ],
        ),
      ],
    ),
  );
}

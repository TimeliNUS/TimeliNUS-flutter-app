import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => new _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController controller = new TextEditingController();

  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails() async {
    final test = await FirebaseFirestore.instance
        .collection('user')
        .where("name", isGreaterThan: 'a')
        .orderBy("name", descending: true)
        .get();
    test.docs.forEach((e) {
      setState(() {
        _userDetails.add(UserDetails.fromJson(e.data()));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Home'),
        elevation: 0.0,
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? new ListView.builder(
                    itemCount: _searchResult.length,
                    itemBuilder: (context, i) {
                      return new Card(
                        child: new ListTile(
                          title: new Text(_searchResult[i].name),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  )
                : new ListView.builder(
                    itemCount: _userDetails.length,
                    itemBuilder: (context, index) {
                      return new Card(
                        child: new ListTile(
                          title: new Text(_userDetails[index].name),
                        ),
                        margin: const EdgeInsets.all(0.0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.name.contains(text)) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List<UserDetails> _searchResult = [];

List<UserDetails> _userDetails = [];

class UserDetails {
  final int id;
  final String email, name;

  UserDetails({this.id, this.email, this.name});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

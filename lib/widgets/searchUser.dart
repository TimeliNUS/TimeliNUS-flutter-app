import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchUser extends StatefulWidget {
  final List<User> groupmates;
  final Function callback;
  const SearchUser(this.callback, {this.groupmates = const []});
  @override
  _SearchUserState createState() => new _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  List<User> _searchResult = [];
  List<User> _userDetails = [];
  TextEditingController controller = new TextEditingController();

  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails() async {
    final test = await FirebaseFirestore.instance
        .collection('user')
        .where("name", isGreaterThan: 'A')
        .orderBy("name", descending: true)
        .get();
    test.docs.forEach((e) {
      setState(() {
        _userDetails.add(User.fromJson(e.data(), e.id, ref: e.reference));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.groupmates.isEmpty) {
      getUserDetails();
    } else {
      setState(() {
        _userDetails = widget.groupmates;
        _searchResult = widget.groupmates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: appTheme.primaryColorLight,
        title: new Text('Add User'),
        elevation: 0.0,
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Theme.of(context).primaryColorLight,
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
              child: ListView.builder(
            itemCount: _searchResult.length,
            itemBuilder: (context, i) {
              return new GestureDetector(
                  onTap: () {
                    widget.callback(_searchResult[i]);
                    Navigator.pop(context);
                  },
                  child: Card(
                    child: new ListTile(
                        title: new Text(_searchResult[i].name),
                        subtitle: Text(_userDetails[i].email)),
                    margin: const EdgeInsets.all(0.0),
                  ));
            },
          )),
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

import 'dart:io';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/profile/profileBloc.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/utils/services/uplodaFile.dart';
import 'package:TimeliNUS/widgets/customCard.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: ProfileScreen());
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(),
        child: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  backgroundColor: appTheme.primaryColorLight,
                  body: Column(
                    children: [
                      TopBar(
                        'Settings',
                        onPressedCallback: () => context.read<AppBloc>().add(AppOnDashboard()),
                      ),
                      ProfileDetails(),
                      // Divider(height: 30)
                      NotificationSettings(),
                      HelpBlock()
                    ],
                  )));
        }));
  }
}

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({Key key}) : super(key: key);

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  File _imageFile;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.deepOrangeAccent),
                child: Icon(Icons.app_settings_alt_rounded, color: Colors.white)),
            Padding(
              padding: EdgeInsets.only(left: 15),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account", style: TextStyle(color: Colors.white)),
                Text("Edit and Manage your account details", style: TextStyle(color: Colors.white))
              ],
            )
          ]),
          Padding(padding: EdgeInsets.only(top: 15)),
          CustomCard(
              // elevation: 3,
              child: Row(children: [
            Container(
              padding: EdgeInsets.only(right: 20),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: InkWell(
                      onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: new Icon(Icons.photo),
                                  title: new Text('View Profile Picture'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                            content: Image.network(context.read<AppBloc>().state.user.profilePicture)));
                                  },
                                ),
                                ListTile(
                                  leading: new Icon(Icons.add_a_photo),
                                  title: new Text('Upload new profile picture'),
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
                                    setState(() {
                                      _imageFile = File(pickedFile.path);
                                    });
                                    print(_imageFile.path);
                                    final url = await uploadImageToFirebase(_imageFile);
                                    context.read<AuthenticationRepository>().updateProfilePicture(url);
                                    Navigator.pop(context);
                                  },
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 10))
                              ],
                            );
                          }),
                      child: Image.network(context.read<AppBloc>().state.user.profilePicture,
                          width: 75, fit: BoxFit.cover))),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.read<AppBloc>().state.user.name, style: TextStyle(fontSize: 24)),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Text(context.read<AppBloc>().state.user.email, style: TextStyle(fontSize: 16))
              ],
            )
          ]))
        ]));
  }
}

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 35, right: 25, left: 25),
        child: Column(children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.deepOrangeAccent),
                child: Icon(Icons.notification_important, color: Colors.white)),
            Padding(
              padding: EdgeInsets.only(left: 15),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notifications", style: TextStyle(color: Colors.white)),
                Text("Configure your notifications at ease", style: TextStyle(color: Colors.white))
              ],
            )
          ]),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            margin: EdgeInsets.only(top: 15),
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: ListTile(
                        title: Text("Alert for invitations"),
                        tileColor: Colors.white,
                        trailing: Checkbox(
                          value: true,
                          onChanged: (bool) => {},
                        ))),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black12,
                  indent: 15,
                  endIndent: 15,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: ListTile(
                        title: Text("Alert for upcoming meetings"),
                        tileColor: Colors.white,
                        trailing: Checkbox(
                          value: true,
                          onChanged: (bool) => {},
                        )))
              ],
            ),
          )
        ]));
  }
}

class HelpBlock extends StatelessWidget {
  const HelpBlock({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 35, right: 25, left: 25),
        child: Column(children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.deepOrangeAccent),
                child: Icon(Icons.notification_important, color: Colors.white)),
            Padding(
              padding: EdgeInsets.only(left: 15),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Help & Feedback", style: TextStyle(color: Colors.white)),
                Text("Reach us with your valuable opinions", style: TextStyle(color: Colors.white))
              ],
            )
          ]),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            margin: EdgeInsets.only(top: 15),
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: ListTile(
                        title: Text("FAQ"),
                        tileColor: Colors.white,
                        trailing: IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () => {},
                        ))),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black12,
                  indent: 15,
                  endIndent: 15,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: ListTile(
                        title: Text("Contact Us"),
                        tileColor: Colors.white,
                        trailing: IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () => {},
                        )))
              ],
            ),
          )
        ]));
  }
}

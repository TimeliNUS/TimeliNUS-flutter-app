import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/customCard.dart';
import 'package:TimeliNUS/widgets/projectScreen/editProjectPopup.dart';
import 'package:TimeliNUS/widgets/projectScreen/newProjectPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: ProjectScreen());

  ProjectScreen({Key key}) : super(key: key);

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> with SingleTickerProviderStateMixin {
  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    super.initState();
  }

  final _projectRepository = ProjectRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);
    return BlocProvider<ProjectBloc>(
        create: (context) => ProjectBloc(projectRepository: _projectRepository)..add(LoadProjects(id)),
        child: BlocBuilder<ProjectBloc, ProjectState>(builder: (context, state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                backgroundColor: appTheme.primaryColorLight,
                body: Column(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Projects", style: TextStyle(color: Colors.white, fontSize: 32)),
                          IconButton(
                              icon: Icon(Icons.add, color: Colors.white),
                              onPressed: () => Navigator.push(
                                  context, SlideRightRoute(page: NewProjectPopup(context.read<ProjectBloc>()))))
                        ],
                      )),
                  (state is ProjectLoaded
                      ? Expanded(
                          child: RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<ProjectBloc>()
                                    .add(LoadProjects(context.read<AppBloc>().getCurrentUser().id));
                                // await Future.delayed(Duration(milliseconds: 1000));
                                await context.read<ProjectBloc>().stream.firstWhere((state) => state is ProjectLoaded);
                              },
                              child: ListView(
                                  children: (state.projects.map((project) => ProjectCard(
                                          project, project.todos.where((todo) => todo.complete == false).toList())))
                                      .toList())))
                      : Container()),
                  // ElevatedButton(
                  //     onPressed: () =>
                  //         context.read<ProjectBloc>().add(LoadProjects(id)),
                  //     child: Text('Reload'))
                ]),
                bottomNavigationBar: BottomBar(1),
              ));
        }));
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final List<Todo> todos;
  const ProjectCard(this.project, this.todos);
  @override
  Widget build(BuildContext context) {
    final double progress =
        (project.todos.length != 0 ? ((project.todos.length - todos.length) / project.todos.length) : 1);
    return Column(verticalDirection: VerticalDirection.up, children: [
      Padding(padding: EdgeInsets.only(bottom: 15)),
      ProjectCardDetail(project.meetings.length, todos, project.id, project.title),
      Row(children: [
        Expanded(
            child: GestureDetector(
          onTap: () =>
              Navigator.push(context, SlideRightRoute(page: EditProjectPopup(project, context.read<ProjectBloc>()))),
          child: CustomCard(
              elevation: 6,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(project.title),
                  Text("Software Engineering Project"),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: appTheme.primaryColorLight),
                      Text(' ' +
                          ((project.deadline.hour != 0)
                              ? DateFormat('MMM dd, yyyy – kk:mm').format(project.deadline)
                              : DateFormat('MMM dd, yyyy').format(project.deadline))),
                      Expanded(
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: CircleAvatar(
                                maxRadius: 12,
                              )))
                    ],
                  )
                ])),
                Padding(padding: EdgeInsets.only(right: 30)),
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 10,
                  percent: progress,
                  animation: true,
                  animationDuration: 500,
                  center: new Text((progress * 100).toInt().toString() + '%',
                      style: TextStyle(color: appTheme.primaryColorLight, fontSize: 14, fontWeight: FontWeight.bold)),
                  progressColor: appTheme.primaryColorLight,
                  animateFromLastPercent: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: HexColor.fromHex('FFD8B4'),
                )
              ])),
        ))
      ]),
    ]);
  }
}

class ProjectCardDetail extends StatelessWidget {
  final String projectId;
  final String projectTitle;
  final int meetingNumber;
  final List<Todo> todos;
  const ProjectCardDetail(this.meetingNumber, this.todos, this.projectId, this.projectTitle);
  @override
  Widget build(BuildContext context) {
    return Container(
        transform: Matrix4.translationValues(0.0, -10.0, 0.0),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(children: [
              Expanded(
                  child: CustomCard(
                      elevation: 5,
                      child: Column(
                        children: [
                          GestureDetector(
                              onTap: () => context
                                  .read<AppBloc>()
                                  .add(AppOnMeeting(projectId: projectId, projectTitle: projectTitle)),
                              child: Row(
                                children: [
                                  Icon(Icons.group, color: Colors.grey.shade500),
                                  Text(' ' + meetingNumber.toString() + ' Scheduled Meetings',
                                      style: appTheme.textTheme.bodyText1),
                                  Expanded(
                                      child:
                                          Text("View", textAlign: TextAlign.right, style: appTheme.textTheme.bodyText1))
                                ],
                              )),
                          Divider(),
                          Row(children: [
                            Icon(Icons.check_box_rounded, color: Colors.grey.shade500),
                            Text(' ' + todos.length.toString() + ' Incompleted Todos',
                                style: appTheme.textTheme.bodyText1),
                            Expanded(
                                child: Text("View", textAlign: TextAlign.right, style: appTheme.textTheme.bodyText1))
                          ]),
                          Padding(
                              padding: EdgeInsets.only(left: 25, top: 10),
                              child: Column(
                                  children: todos
                                      .take(2)
                                      .map((todo) => Row(children: [
                                            Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey.shade500),
                                            Text(todo.title, style: appTheme.textTheme.bodyText1),
                                          ]))
                                      .toList()

                                  // Row(children: [
                                  //   Icon(Icons.check_box_outline_blank_rounded,
                                  //       color: Colors.grey.shade500),
                                  //   Text(' Peer Evaluation',
                                  //       style: appTheme.textTheme.bodyText1),
                                  // ])
                                  ))
                        ],
                      )))
            ])));
  }
}

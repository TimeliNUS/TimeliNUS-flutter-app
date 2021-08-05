import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoEvent.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoState.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/customCard.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashboardScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: DashboardScreen());
  DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
        appTheme.primaryColorLight,
        Scaffold(
            bottomNavigationBar: BottomBar(0),
            body: Column(
              children: [
                DashboardWelcomeBar(),
                Expanded(
                    child: ListView(
                  children: [
                    DashboardProjects(),
                    DashboardMeetings(),
                    DashboardTodos(),
                  ],
                ))
              ],
            )));
  }
}

class DashboardWelcomeBar extends StatelessWidget {
  const DashboardWelcomeBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: appTheme.primaryColorLight,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Hello, " + context.read<AppBloc>().getCurrentUser().name ?? ' ' + "!",
                style: TextStyle(fontSize: 24, color: Colors.white)),
            Text(DateFormat('EEE, M/d/y').format(DateTime.now()), style: TextStyle(fontSize: 14, color: Colors.white))
          ]),
          GestureDetector(
              onTap: () => context.read<AppBloc>().add(AppOnProfile()),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    context.read<AppBloc>().state.user.profilePicture,
                    cacheWidth: 50,
                    cacheHeight: 50,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  )))
        ],
      ),
    );
  }
}

class DashboardProjects extends StatelessWidget {
  DashboardProjects({Key key}) : super(key: key);
  final _projectRepository = ProjectRepository();

  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);
    return BlocProvider<ProjectBloc>(
        create: (context) => ProjectBloc(projectRepository: _projectRepository)..add(LoadProjects(id)),
        child: BlocBuilder<ProjectBloc, ProjectState>(builder: (context, state) {
          return Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Projects', style: TextStyle(fontSize: 24)),
                        InkWell(
                            child: Text('View All', style: TextStyle(color: Colors.grey)),
                            onTap: () => context.read<AppBloc>().add(AppOnProject()))
                      ],
                    )),
                SizedBox(
                    height: 165,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                        // mainAxisSize: MainAxisSize.max,
                        padding: EdgeInsets.only(bottom: 10),
                        scrollDirection: Axis.horizontal,
                        children: state.projects
                            .map((project) => DashboardProjectCard(
                                project,
                                project.todos.where((todo) => todo.complete == false).toList().length,
                                project.noOfMeetings))
                            .toList()))
              ],
            ),
          );
        }));
  }
}

class DashboardProjectCard extends StatelessWidget {
  final Project project;
  final int todosLength;
  final int meetingLength;

  const DashboardProjectCard(this.project, this.todosLength, this.meetingLength, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress =
        (project.todos.length != 0 ? ((project.todos.length - todosLength) / project.todos.length) : 0);
    return CustomCard(
      padding: 15,
      elevation: 6,
      margin: EdgeInsets.only(left: 25, top: 15),
      child: IntrinsicWidth(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.title),
              Text(project.moduleCode),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                      children: project.groupmates
                          .map((groupmate) => CircleAvatar(
                                backgroundImage: Image.network(groupmate.profilePicture).image,
                                maxRadius: 10,
                              ))
                          .take(4)
                          .toList()
                            ..add(project.groupmates.length > 4
                                ? CircleAvatar(
                                    maxRadius: 10,
                                    child: Text('+' + (project.groupmates.length - 4).toString(),
                                        style: TextStyle(fontSize: 10)))
                                : CircleAvatar(
                                    radius: 0,
                                  )))),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 15, color: Colors.grey),
                  Text(
                      ' ' +
                          ((project.includeTime)
                              ? DateFormat('MMM dd, yyyy – HH:mm').format(project.deadline)
                              : DateFormat('MMM dd, yyyy').format(project.deadline)),
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              CustomPadding(),
            ]),
            // Padding(padding: EdgeInsets.only(right: 30)),
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
          ]),
          Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Icon(Icons.check_box_outlined, size: 15, color: Colors.grey),
              Text(' ' + todosLength.toString() + ' Incompleted', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            Padding(padding: EdgeInsets.only(right: 10)),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Icon(Icons.check_box_outlined, size: 15, color: Colors.grey),
              Text(' ' + meetingLength.toString() + ' Meeting', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ])
          ]),
        ]),
      ),
    );
  }
}

class DashboardMeetings extends StatelessWidget {
  DashboardMeetings({Key key}) : super(key: key);
  final _meetingRepository = MeetingRepository();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Today's Meeting",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 24),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            width: double.infinity,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                boxShadow: [BoxShadow(color: HexColor.fromHex('FFDCC8'), spreadRadius: 4)],
                border: Border.all(color: appTheme.primaryColorLight, width: 2.5)),
            child: BlocProvider<MeetingBloc>(
                create: (context) =>
                    MeetingBloc(_meetingRepository)..add(TodayMeeting(context.read<AppBloc>().state.user.id)),
                child: BlocBuilder<MeetingBloc, MeetingState>(builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        state.meetings.mapIndexed((index, meeting) => DashboardMeetingItem(meeting, index)).toList(),
                  );
                })),
          ),
        ]));
  }
}

class DashboardMeetingItem extends StatelessWidget {
  final Meeting meeting;
  final int index;
  const DashboardMeetingItem(this.meeting, this.index);
  @override
  Widget build(BuildContext context) {
    int diff = meeting.selectedTimeStart.difference(DateTime.now()).inMinutes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      index != 0 ? Divider(color: appTheme.primaryColor.withOpacity(0.75), height: 40) : Container(),
      Text(meeting.title),
      Text(DateFormat.jm().format(meeting.selectedTimeStart).toLowerCase() +
          ' - ' +
          DateFormat.jm()
              .format(meeting.selectedTimeStart.add(Duration(minutes: meeting.timeLength.toInt())))
              .toLowerCase()),
      Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.alarm, size: 20, color: appTheme.primaryColor),
                Text(diff < -(meeting.timeLength)
                    ? ' Earlier today'
                    : (diff < 0
                        ? ' Now'
                        : ' In ' + timeago.format(meeting.selectedTimeStart, allowFromNow: true, locale: 'en_short'))),
                Padding(padding: EdgeInsets.only(right: 10)),
                Icon(Icons.location_pin, size: 20, color: appTheme.primaryColor),
                Text(' ' + meeting.meetingVenue),
                // .toString().split('.')[1]),
              ]),
              diff.abs() < meeting.timeLength
                  ? ElevatedButton(
                      onPressed: () => {},
                      child: Text('Join Now'),
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all<Color>(appTheme.primaryColorLight),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))))
                  : Container()
            ],
          ))
    ]);
    // }));
  }
}

class DashboardTodos extends StatefulWidget {
  DashboardTodos({Key key}) : super(key: key);
  final _todoRepository = TodoRepository();
  @override
  _DashboardTodosState createState() => _DashboardTodosState();
}

class _DashboardTodosState extends State<DashboardTodos> {
  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);

    return BlocProvider<TodoBloc>(
        create: (context) => TodoBloc(todoRepository: widget._todoRepository)..add(TodayTodo(id)),
        child: BlocBuilder<TodoBloc, TodoState>(builder: (context, state) {
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              child: state.todos != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          "Today's Todos",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 24),
                        ),
                        InkWell(
                            child: Text('View All', style: TextStyle(color: Colors.grey)),
                            onTap: () => context.read<AppBloc>().add(AppOnTodo()))
                      ]),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: appTheme.primaryColorLight,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              CircularPercentIndicator(
                                radius: 80.0,
                                lineWidth: 10,
                                percent: state.todos.length != 0 ? state.progress : 1,
                                animation: true,
                                animationDuration: 500,
                                center: new Text((state.progress * 100).toInt().toString() + '%',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                progressColor: Colors.white,
                                animateFromLastPercent: true,
                                circularStrokeCap: CircularStrokeCap.round,
                                backgroundColor: HexColor.fromHex('FFD5A5'),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  height: 80,
                                  child: VerticalDivider(
                                    width: 3,
                                    thickness: 3,
                                    color: HexColor.fromHex('FFD5A5'),
                                  )),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                    state.todos.where((x) => x.complete).toList().length.toString() +
                                        '/' +
                                        state.todos.length.toString(),
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                                Text('Completed', style: TextStyle(color: Colors.white))
                              ]),
                            ]),
                            // ...(state.todos
                            //     .map((todo) => ProjectTodoCard(todo))
                            //     .toList()),
                            ...(groupBy(state.todos, (Todo todo) => todo.project.id)
                                .values
                                .map((value) => ProjectTodoCard(value))
                                .toList())
                          ],
                        ),
                      ),
                    ])
                  : Container());
        }));
  }
}

class ProjectTodoCard extends StatefulWidget {
  final List<Todo> todos;
  const ProjectTodoCard(this.todos, {Key key}) : super(key: key);
  @override
  _ProjectTodoCardState createState() => _ProjectTodoCardState();
}

class _ProjectTodoCardState extends State<ProjectTodoCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.todos[0].project.title),
            Divider(color: appTheme.primaryColorLight, thickness: 1.5),
            ...widget.todos.map((todo) => _ProjectTodoCardItem(todo))
          ],
        ));
  }
}

class _ProjectTodoCardItem extends StatefulWidget {
  Todo todo;
  _ProjectTodoCardItem(this.todo, {Key key}) : super(key: key);

  @override
  __ProjectTodoCardItemState createState() => __ProjectTodoCardItemState();
}

class __ProjectTodoCardItemState extends State<_ProjectTodoCardItem> {
  bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.todo.title),
        SizedBox(
            height: 24.0,
            width: 24.0,
            child: Container(
                child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    value: isChecked ?? widget.todo.complete,
                    onChanged: (boolean) {
                      setState(() => isChecked = (isChecked != null ? !isChecked : !widget.todo.complete));
                      context.read<TodoBloc>().add(UpdateTodo(context
                          .read<TodoBloc>()
                          .state
                          .todos
                          .firstWhere((element) => element.id == widget.todo.id)
                          .copyWith(complete: isChecked)));
                    })))
      ],
    );
  }
}

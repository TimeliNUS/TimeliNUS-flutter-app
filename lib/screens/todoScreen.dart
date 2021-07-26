import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/todoScreen/editTodoPopup.dart';
import 'package:TimeliNUS/widgets/todoScreen/newTodoPopup.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  final TodoRepository _todoRepository = TodoRepository();
  static Page page(String projectId, String projectTitle) =>
      MaterialPage(child: TodoScreen(projectId: projectId, projectTitle: projectTitle));
  TodoScreen({this.projectId, this.projectTitle, Key key}) : super(key: key);
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);
    return BlocProvider<TodoBloc>(
        create: (context) => TodoBloc(todoRepository: widget._todoRepository)
          ..add(LoadTodos(widget.projectId ?? id, isSearchByProject: widget.projectId != null)),
        child: BlocBuilder<TodoBloc, TodoState>(builder: (context, state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  bottomNavigationBar: BottomBar(2),
                  body: Container(
                      color: appTheme.primaryColorLight,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TopBar(widget.projectTitle ?? "My Todos",
                            subtitle: widget.projectTitle != null ? "Project Todos " : null,
                            // subtitle: "Example Project",
                            rightWidget: CircularProgress()),
                        Expanded(
                          child: CustomCard(),
                        ),
                      ]))));
        }));
  }
}

class CircularProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(buildWhen: (previousState, state) {
      return previousState != state;
    }, builder: (context, state) {
      return CircularPercentIndicator(
        radius: 60.0,
        lineWidth: 10,
        percent: (state is TodoLoaded ? state.progress : 0),
        animation: true,
        animationDuration: 500,
        center: new Text((state.progress * 100).toInt().toString() + "%",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        progressColor: Colors.white,
        animateFromLastPercent: true,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: HexColor.fromHex('FFD8B4'),
      );
    });
  }
}

class CustomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0))),
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Todo", style: TextStyle(fontSize: 24, color: appTheme.primaryColorLight)),
                    IconButton(
                      icon: Icon(Icons.add, color: appTheme.primaryColorLight),
                      onPressed: () =>
                          Navigator.push(context, SlideRightRoute(page: NewTodoPopup(context.read<TodoBloc>()))),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Padding(padding: EdgeInsets.only(bottom: 15)),
                Expanded(
                  // child: SingleChildScrollView(
                  //     clipBehavior: Clip.hardEdge,

                  child: TodoList(),
                  // )
                )
              ],
            )));
  }
}

class TodoList extends StatefulWidget {
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> with SingleTickerProviderStateMixin {
  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(buildWhen: (previousState, state) {
      return previousState != state;
    }, builder: (context, state) {
      if (state is TodoNotLoaded) {
        return Container(child: Text("Error occur, Todos not loaded"));
      }
      return RefreshIndicator(
          onRefresh: () async {
            context.read<TodoBloc>().add(LoadTodos(context.read<AppBloc>().getCurrentUser().id));
            // await Future.delayed(Duration(milliseconds: 1000));
            await context.read<TodoBloc>().stream.firstWhere((state) => state is TodoLoaded);
          },
          child: Theme(
              data: Theme.of(context).copyWith(shadowColor: Colors.transparent, canvasColor: Colors.transparent),
              child: ReorderableListView(
                  clipBehavior: Clip.hardEdge,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final List<Todo> currentTodos = state.todos;
                      final Todo item = currentTodos.removeAt(oldIndex);
                      currentTodos.insert(newIndex, item);
                      context
                          .read<TodoBloc>()
                          .add(ReorderTodos(currentTodos, context.read<AppBloc>().getCurrentUser().id));
                    });
                  },
                  children: context
                      .select((TodoBloc bloc) => bloc.state.todos)
                      .map((todo) => //     clipBehavior: Clip.hardEdge,
                          Container(
                              key: Key(todo.id ?? DateTime.now().toString()),
                              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
                              child: TodoItem(todo)))
                      .toList())));
    });
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  final bool hasCheckbox;
  const TodoItem(this.todo, {this.hasCheckbox = true});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool isChecked;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
                onTap: () => Navigator.push(
                    context, SlideRightRoute(page: EditTodoPopup(widget.todo, context.read<TodoBloc>()))),
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(children: [
                          Text(
                            widget.todo.title,
                            style: TextStyle(color: appTheme.primaryColor),
                          )
                        ]),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: appTheme.primaryColorLight),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            Text(
                                widget.todo.deadline != null
                                    ? (widget.todo.deadline.hour != 0
                                        ? DateFormat('MMM dd, yyyy – kk:mm').format(widget.todo.deadline)
                                        : DateFormat('MMM dd, yyyy').format(widget.todo.deadline))
                                    : "No deadline set",
                                style: TextStyle(color: appTheme.primaryColor))
                          ],
                        )
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: appTheme.primaryColorLight, spreadRadius: 1, blurRadius: 1),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40),
          ),
          widget.hasCheckbox
              ? Transform.scale(
                  scale: 1.2,
                  child: SizedBox(
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
                              }))))
              // )
              : Container()
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: 10)),
    ]);
  }
}

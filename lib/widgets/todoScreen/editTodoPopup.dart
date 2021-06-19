import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/todoScreen/newTodoPopup.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTodoPopup extends StatefulWidget {
  final Todo todoToEdit;
  final TodoBloc todosBloc;
  const EditTodoPopup(this.todoToEdit, this.todosBloc);
  @override
  State<EditTodoPopup> createState() => _EditTodoPopupState();
}

class _EditTodoPopupState extends State<EditTodoPopup> {
  DateTime deadlineValue;
  TextEditingController textController = new TextEditingController();
  TextEditingController noteController;
  List<User> pics;
  String userId;

  @override
  void initState() {
    super.initState();
    userId = context.read<AppBloc>().getCurrentUser().id;
    textController = new TextEditingController(text: widget.todoToEdit.title);
    noteController = new TextEditingController(text: widget.todoToEdit.note);
    deadlineValue = widget.todoToEdit.deadline;
    pics = widget.todoToEdit.pic ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>(
        create: (context) => widget.todosBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(() => Navigator.pop(context), "Todo Details",
                          rightWidget: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                widget.todosBloc
                                    .add(DeleteTodo(widget.todoToEdit, userId));
                                Navigator.pop(context);
                              })),
                      Expanded(
                          child: GestureDetector(
                              onTap: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40.0),
                                          topLeft: Radius.circular(40.0))),
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 30, right: 30, top: 15),
                                      child: ListView(
                                        children: [
                                          // TopBar(),
                                          PopupInput(textController),
                                          customPadding(),
                                          PopupDropdown(
                                            dropdownLabel: 'Module Project',
                                          ),
                                          customPadding(),
                                          PersonInChargeChips(
                                              widget.todoToEdit.pic,
                                              "Person in Charge",
                                              callback: (val) {
                                            setState(() => pics = val);
                                          }),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          DeadlineInput(
                                            (val) => setState(
                                                () => deadlineValue = val),
                                            true,
                                            initialTime:
                                                widget.todoToEdit.deadline,
                                          ),
                                          customPadding(),
                                          NotesInput(noteController),
                                        ],
                                      ))))),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                appTheme.primaryColorLight)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text("Update",
                                            style: appTheme.textTheme.bodyText2
                                                .apply(color: Colors.white))),
                                    onPressed: () {
                                      widget.todosBloc.add(UpdateTodo(Todo(
                                          textController.text,
                                          id: widget.todoToEdit.id,
                                          note: noteController.text,
                                          complete: widget.todoToEdit.complete,
                                          pic: pics,
                                          deadline: deadlineValue)));
                                      Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

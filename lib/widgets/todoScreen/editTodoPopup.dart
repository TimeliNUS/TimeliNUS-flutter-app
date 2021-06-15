import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
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
  @override
  void initState() {
    super.initState();
    textController = new TextEditingController(text: widget.todoToEdit.title);
    noteController = new TextEditingController(text: widget.todoToEdit.note);
  }

  @override
  Widget build(BuildContext context) {
    final todosBloc = TodoBloc(todoRepository: context.read<TodoRepository>());
    return BlocProvider<TodoBloc>(
        create: (context) => todosBloc,
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
                                widget.todosBloc.add(DeleteTodo(
                                    widget.todoToEdit,
                                    context
                                        .read<AppBloc>()
                                        .getCurrentUser()
                                        .id));
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
                                          PersonInChargeChips([
                                            context.select((AppBloc bloc) =>
                                                    bloc.state.user.name) ??
                                                "Myself"
                                          ], "Person in Charge"),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          DeadlineInput(
                                              (val) => setState(
                                                  () => deadlineValue = val),
                                              true),
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
                                          deadline: deadlineValue)));
                                      Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

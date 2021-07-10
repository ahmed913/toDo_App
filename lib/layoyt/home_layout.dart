import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/shared/components/components.dart';
import 'package:to_do_app/shared/cubit/cubit.dart';
import 'package:to_do_app/shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeLayout extends StatelessWidget
{

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates >(
        listener: (BuildContext context,AppStates states) {
          if(states is AppInsertDatabaseState)
            {
              Navigator.pop(context);
            }
        },
        builder: (BuildContext context, AppStates states ) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: states is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator(),),
            ),

            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                  // title: Text("Tasks "),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: " Done "
                  // title: Text(" Done "),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: " Archived ",
                  // title: Text(" Archived "),
                ),
              ],
            ),

            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if(cubit.isBottomSheetShown)
                {
                  if(formKey.currentState.validate())
                  {
                    cubit.insertToDatabase(title: titleController.text, time: timeController.text, date: dateController.text);
                  }

                }
                else {
                  cubit.isBottomSheetShown = true;
                  scaffoldKey.currentState.showBottomSheet(
                        (context) => Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.grey[200],
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              type: TextInputType.text,
                              validate: (String value){
                                if(value.isEmpty){
                                  return "title must not be embty";
                                }
                                return null;
                              },
                              label: "Task Title",
                              prefix: Icons.title,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            defaultFormField(
                              controller: timeController,
                              type: TextInputType.text,
                              onTap: (){
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text = value.format(context).toString();
                                });
                              },
                              validate: (String value){
                                if(value.isEmpty){
                                  return "time must not be embty";
                                }
                                return null;
                              },
                              label: "Task Time",
                              prefix: Icons.watch_later,
                            ),
                            SizedBox(
                              height: 15,
                            )
                            ,
                            defaultFormField(
                              controller: dateController,
                              type: TextInputType.datetime,
                              onTap: (){
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2022-02-03'),
                                ).then((value)
                                {
                                  dateController.text = DateFormat.yMMMd().format(value);

                                });
                              },
                              validate: (String value){
                                if(value.isEmpty){
                                  return "date must not be embty";
                                }
                                return null;
                              },
                              label: "Task Date",
                              prefix: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).closed.then((value) {
                    cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);

                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
            ),
          );
        } ,
      ),
    );
  }
}


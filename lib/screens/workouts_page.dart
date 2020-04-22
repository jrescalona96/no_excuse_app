import "package:flutter/material.dart";

// class imports
import "package:lfti_app/classes/Constants.dart";
import "package:lfti_app/classes/User.dart";
import "package:lfti_app/classes/Workout.dart";
import "package:lfti_app/classes/Routine.dart";
import "package:lfti_app/classes/Crud.dart";

// component imports
import "package:lfti_app/components/workout_card.dart";
import "package:lfti_app/components/bottom_navigation_button.dart";
import "package:lfti_app/components/menu.dart";
import "package:lfti_app/components/empty_state_notification.dart";
import "package:lfti_app/components/custom_dialog_button.dart";
import "package:lfti_app/components/custom_floating_action_button.dart";

class WorkoutsPage extends StatefulWidget {
  final User _currentUser;
  WorkoutsPage(this._currentUser);

  @override
  _WorkoutsPageState createState() => _WorkoutsPageState(_currentUser);
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  User _currentUser;
  Crud crudController;

  _WorkoutsPageState(this._currentUser) {
    if (_currentUser.getWorkoutList().isEmpty) {
      this._currentUser.setWorkoutList(List<Workout>());
    }
    crudController = Crud(_currentUser);
  }

  void _showDeleteConfirmationDialog(int index) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Workout"),
          content: Text("Are you sure you want to delete Workout?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          backgroundColor: kCardBackground.withOpacity(0.9),
          actions: <Widget>[
            CustomDialogButton(
              label: "CANCEL",
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CustomDialogButton(
              label: "DELETE",
              onPressed: () {
                setState(() {
                  this._currentUser.deleteWorkoutAt(index);
                  crudController.updateWorkoutList();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateNewWorkoutDialog() async {
    final _nameTextController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Workout Name"),
          content: TextFormField(
              controller: _nameTextController,
              keyboardType: TextInputType.text),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          backgroundColor: kCardBackground.withOpacity(0.9),
          actions: <Widget>[
            CustomDialogButton(
              label: "CREATE",
              onPressed: () {
                if (_nameTextController.text != null) {
                  this._currentUser.addWorkout(
                        Workout(
                          name: _nameTextController.text,
                          routines: List<Routine>(),
                        ),
                      );
                  int lastIndex = this._currentUser.getWorkoutList().length - 1;
                  Navigator.pushNamed(context, "/updateWorkout",
                      arguments: this._currentUser.getWorkoutAt(lastIndex));
                } else {
                  print("Empty Name Field!");
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Container> _getWorkoutListCards() {
    var _workoutList = _currentUser.getWorkoutList();
    var contianers = List<Container>();
    for (int i = 0; i < _workoutList.length; i++) {
      contianers.add(
        Container(
          key: Key(i.toString() + _workoutList[i].name),
          child: WorkoutCard(
              shadowOn: true,
              onOptionsTap: () => _showDeleteConfirmationDialog(i),
              optionsIcon: Icons.delete,
              user: this._currentUser,
              index: i,
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/updateWorkout',
                        arguments: _currentUser.getWorkoutAt(i))
                    .then((val) {
                  setState(() {
                    this._currentUser.setWorkoutAt(i, val);
                  });
                });
              }),
        ),
      );
    }
    return contianers;
  }

  void _onReorder(int oldIndex, int newIndex) {
    var workoutList = _currentUser.getWorkoutList();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      var r = workoutList.removeAt(oldIndex);
      workoutList.insert(newIndex, r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        title: Text("Workouts"),
      ),
      drawer: Menu(_currentUser),
      body: _currentUser.getWorkoutList().isNotEmpty
          ? Theme(
              data: ThemeData(canvasColor: Colors.transparent),
              child: ReorderableListView(
                onReorder: _onReorder,
                children: _getWorkoutListCards(),
              ),
            )
          : EmptyStateNotification(sub: "Create workout routines first."),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.add,
        onPressed: () => _showCreateNewWorkoutDialog(),
      ),
      bottomNavigationBar: BottomNavigationButton(
        label: "START WORKOUT",
        action: () => Navigator.pushNamed(context, "/viewWorkouts",
            arguments: this._currentUser),
        color: kBlueButtonColor,
      ),
    );
  }
}

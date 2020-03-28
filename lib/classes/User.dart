import "dart:core";
// firebase imports
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

// class imports
import "package:lfti_app/classes/Routine.dart";
import "package:lfti_app/classes/Workout.dart";
import "package:lfti_app/classes/Session.dart";
import "package:lfti_app/classes/Exercise.dart";

class User {
  // user credentials
  FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authRes;
  DocumentReference _firestoreReference;
  DocumentSnapshot _document;

  /// user data
  List<Workout> _workouts;
  List _checklist;
  String _firstName;
  String _lastName;
  String _email;
  int _age = 29;
  // TODO: set up date formatter or create own class
  Map<String, int> _dob = {"month": 9, "day": 6, "year": 1990};
  Session _currentSession = null;
  Map _lastSession = null;
  Map _nextSession = null;

  void login(String email, String password) async {
    try {
      _setAuthResult(await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password));
      await _setDatabaseReference();
      await _setDocumentSnapshot();
      await _initUserData();
      print("Success: Loggin in as " + _authRes.user.uid);
    } catch (e) {
      print("Error: Unable to Log in! " + e.toString());
    }
  }

  void _initUserData() {
    try {
      this._workouts = _buildWorkoutList();
      this._firstName = getDocument().data["firstName"];
      this._lastName = getDocument().data["lastName"];
      this._email = getDocument().data["email"];
      this._age = 29; // TODO: write algo to compute age
      this._dob = {
        "month": getDocument().data["dob"]["month"],
        "day": getDocument().data["dob"]["day"],
        "year": getDocument().data["dob"]["year"]
      };
      this._lastSession = getDocument().data["lastSession"];
      this._nextSession = getDocument().data["nextSession"];
      this._checklist = getDocument().data["checklist"];
      print("Success: User Initialized!");
    } catch (e) {
      print("Error: Failed to initialize user! " + e.toString());
    }
  }

  /// setters
  void _setAuthResult(var res) {
    this._authRes = res;
  }

  void _setDatabaseReference() {
    try {
      this._firestoreReference =
          Firestore.instance.collection("users").document(_authRes.user.uid);
      print("Success: Document References set!");
    } catch (e) {
      print("Error: Document Reference not set! " + e.toString());
    }
  }

  void _setDocumentSnapshot() async {
    try {
      this._document = await _firestoreReference.get();
      print("Success: Document Snapshot set!");
    } catch (e) {
      print("Error: Document Snapshot not set! " + e.toString());
    }
  }

  void _setDOB() {
    this._dob = {
      "month": getDocument().data["dob"]["month"],
      "day": getDocument().data["dob"]["day"],
      "year": getDocument().data["dob"]["year"]
    };
  }

  void setLastSession(Map data) {
    this._lastSession = data;
  }

  void setSession(Session s) {
    if (s != null)
      this._currentSession = s;
    else
      print("Setting an empty Session!");
  }

  void setChecklist(List<String> l) {
    this._checklist = l;
  }

  void setWorkoutList(List<Workout> l) {
    this._workouts = l;
  }

  bool isLoggedIn() {
    return getDocument() != null && getAuth() != null;
  }

  /// getters
  AuthResult getAuth() {
    return _authRes;
  }

  DocumentReference getFirestoreReference() {
    return _firestoreReference;
  }

  DocumentSnapshot getDocument() {
    return _document;
  }

  String getFirstName() {
    return _firstName;
  }

  String getLastName() {
    return _lastName;
  }

  String getEmail() {
    return _email;
  }

  Map getDOB() {
    return _dob;
  }

  Map getLastSession() {
    return _lastSession == null
        ? getDocument().data["lastSession"]
        : _lastSession;
  }

  Map getNextSession() {
    return _lastSession != null
        ? getDocument().data["nextSession"]
        : _lastSession;
  }

  List getChecklist() {
    return _checklist == null ? getDocument().data["checklist"] : _checklist;
  }

  List<Workout> getWorkoutList() {
    return this._workouts;
  }

  int getAge() {
    return _age;
  }

  Workout getWorkoutAt(int index) {
    return this._workouts[index];
  }

  Session getSession() {
    return this._currentSession;
  }

  /// helper methods
  List<Workout> _buildWorkoutList() {
    try {
      List<Workout> w = List<Workout>();
      for (var item in getDocument().data["workouts"]) {
        w.add(_buildWorkout(item));
      }
      print("Success: Workout List set!");
      return w;
    } catch (e) {
      print("Error: Unable to Build workout list! " + e.toString());
    }
  }

  Workout _buildWorkout(Map w) {
    return Workout(
      id: w["id"],
      name: w["name"],
      description: w["description"],
      routines: _buildRoutineList(
        w["routines"],
      ),
    );
  }

  List<Routine> _buildRoutineList(List r) {
    int _defaultTime = 120;
    var routines = List<Routine>();
    for (var item in r) {
      routines.add(Routine(
        exercise: Exercise(
            name: item["exercise"]["name"], focus: item["exercise"]["focus"]),
        reps: item["reps"],
        sets: item["sets"],
        timeToPerformInSeconds: item["timeToPerformInSeconds"] == null
            ? _defaultTime
            : item["timeToPerformInSeconds"],
      ));
    }
    return routines;
  }
}

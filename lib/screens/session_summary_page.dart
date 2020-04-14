import "package:flutter/material.dart";
import "dart:core";
import "package:charts_flutter/flutter.dart" as charts;

// component imports
import "package:lfti_app/components/bottom_navigation_button.dart";
import "package:lfti_app/components/summary_card.dart";
import "package:lfti_app/components/menu.dart";

// class imports
import "package:lfti_app/classes/Constants.dart";
import "package:lfti_app/classes/Session.dart";
import "package:lfti_app/classes/User.dart";
import "package:lfti_app/classes/Crud.dart";

class SessionSummaryPage extends StatefulWidget {
  final Map _args;
  SessionSummaryPage(this._args);

  @override
  _SessionSummaryPageState createState() =>
      _SessionSummaryPageState(this._args);
}

class _SessionSummaryPageState extends State<SessionSummaryPage> {
  User _currentUser;
  Session _session;

  _SessionSummaryPageState(Map args) {
    this._currentUser = args["user"];
    this._session = args["session"];
  }

  Widget _getTimeWidget() {
    RegExp exp = new RegExp(r"(\d\d)");
    Iterable<RegExpMatch> matches = exp.allMatches(_session.getElapseTime());
    String min = matches.elementAt(0).group(0).replaceAll("0", "");
    String sec = matches.elementAt(1).group(0);
    String label = "TIME";
    Widget widget;

    if (min == "") {
      widget = SummaryCard(
        label: label,
        data: sec,
        sub: "SEC",
      );
    } else {
      widget = Row(
        children: <Widget>[
          SummaryCard(label: label, data: min, sub: "MIN"),
          SizedBox(width: kSizedBoxHeight),
          SummaryCard(
            label: "",
            data: sec,
            sub: "SEC",
          )
        ],
      );
    }
    return widget;
  }

  List<charts.Series<CountedSets, String>> _generateChartData() {
    final data = [
      CountedSets(
        category: "PERFORM",
        data: this._session.getPerformedSets(),
        color: kBlueButtonColor,
      ),
      CountedSets(
        category: "SKIP",
        data: this._session.getSkippedSets(),
        color: kRedButtonColor.withOpacity(0.6),
      ),
    ];
    return [
      charts.Series<CountedSets, String>(
        data: data,
        id: "Result",
        domainFn: (CountedSets count, _) => count.category,
        measureFn: (CountedSets count, _) => count.data,
        colorFn: (CountedSets count, _) =>
            charts.ColorUtil.fromDartColor(count.color),
        labelAccessorFn: (CountedSets row, _) => row.category,
      )
    ];
  }

  // update session obj and database
  void _updateLastSession() {
    _currentUser.setLastSession({
      "name": _session.getWorkout().name,
      "description": "Date: " +
          _session.date +
          " Time: " +
          _session.getElapseTime() +
          " sec",
      "date": _session.date
    });
    Crud(this._currentUser).updateFireStore(
      "lastSession",
      _currentUser.getLastSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateChartData();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text(
          "Session Summary",
          style: kSmallTextStyle.copyWith(color: Colors.white),
        ),
      ),
      drawer: Menu(_currentUser),
      body: Container(
        margin: kContentPadding,
        child: ListView(
          children: <Widget>[
            SummaryCard(
              label: "",
              data: _session.getWorkout().name,
              subData: _session.getWorkout().description,
              style: kLargeBoldTextStyle1x,
            ),
            Container(
              child: _getTimeWidget(),
            ),
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SummaryCard(
                      label: "PERFORMED",
                      data: _session.getPerformedRoutines().length.toString(),
                      sub: "EXERCISES",
                    ),
                    SummaryCard(
                      label: "SKIPPED",
                      data: _session.getSkippedRoutines().length.toString(),
                      sub: "EXERCISES",
                    ),
                  ],
                ),
                SizedBox(width: kSizedBoxHeight * 3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SummaryCard(
                        label: "",
                        data: _session.getPerformedSets().toString(),
                        sub: "SETS"),
                    SummaryCard(
                        label: "",
                        data: _session.getSkippedSets().toString(),
                        sub: "SETS"),
                  ],
                ),
              ],
            ),
            Container(
              height: 300.0,
              width: 300.0,
              child: charts.PieChart(
                _generateChartData(),
                defaultRenderer:
                    charts.ArcRendererConfig(arcRendererDecorators: [
                  charts.ArcLabelDecorator(
                    insideLabelStyleSpec: charts.TextStyleSpec(
                      fontSize: 16,
                      color: charts.ColorUtil.fromDartColor(Colors.white),
                    ),
                    outsideLabelStyleSpec: charts.TextStyleSpec(
                      fontSize: 16,
                      color: charts.ColorUtil.fromDartColor(Colors.black),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
          label: "DONE",
          action: () {
            _updateLastSession();
            Navigator.pushNamed(
              context,
              "/dashboard",
              arguments: _currentUser,
            );
          },
          color: kBlueButtonColor),
    );
  }
}

class CountedSets {
  String category;
  int data;
  Color color;
  CountedSets({@required this.data, @required this.category, this.color});
}

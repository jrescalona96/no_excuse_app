import "package:flutter/material.dart";
import "package:lfti_app/classes/Constants.dart";

class CustomDropdownMenu extends StatefulWidget {
  final String initialValue;
  final List<String> items;

  CustomDropdownMenu({this.initialValue, this.items});

  final _customDropdownMenuState = _CustomDropdownMenuState();
  @override
  _CustomDropdownMenuState createState() {
    _customDropdownMenuState._initDropdownValue(this.initialValue, this.items);
    return _customDropdownMenuState;
  }

  String getValue() {
    print("New Value : " + _customDropdownMenuState.getValue());
    return _customDropdownMenuState.getValue();
  }
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  String _dropdownValue;
  List<String> _items;

  void _initDropdownValue(String val, List<String> l) {
    this._dropdownValue = val;
    this._items = l;
  }

  String getValue() {
    return this._dropdownValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: this._dropdownValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      isExpanded: true,
      isDense: true,
      items: this._items.map((val) {
        return DropdownMenuItem(
          value: val,
          child: Text(val == null ? "null" : val.toString()),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          this._dropdownValue = val;
          print("Selected New Value : $_dropdownValue");
        });
      },
    );
  }
}
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'unit.dart';

const _padding = EdgeInsets.all(16.0);

/// [ConverterRoute] where users can input amounts to convert in one [Unit]
/// and retrieve the conversion in another [Unit] for a specific [Category].
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class ConverterRoute extends StatefulWidget {
  /// This [Category]'s name.
  final String name;

  /// Color for this [Category].
  final Color color;

  /// Units for this [Category].
  final List<Unit> units;

  /// This [ConverterRoute] requires the name, color, and units to not be null.
  const ConverterRoute({
    @required this.name,
    @required this.color,
    @required this.units,
  })  : assert(name != null),
        assert(color != null),
        assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<ConverterRoute> {
  // TODO: Set some variables, such as for keeping track of the user's input
  // value and units
  double _inputValue = 1.0; 
  Unit _inputUnit;
  double _outputValue;
  Unit _outputUnit;

  @override
  void initState() {
    super.initState();
    _inputValue = 1.0;
    _inputUnit = widget.units[0];
    _outputUnit = widget.units[1];
    _outputValue = _inputValue * _outputUnit.conversion / _inputUnit.conversion;
  }

  // TODO: Add other helper functions. We've given you one, _format()

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Create the 'input' group of widgets. This is a Column that
    // includes the output value, and 'from' unit [Dropdown].
    var inputWidgets = Container(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Input',
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ), 
            ),
            style: Theme.of(context).textTheme.display1,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (newInputValue) { 
              setState( () {
                _inputValue = double.tryParse(newInputValue);
                _outputValue = _inputValue * _outputUnit.conversion / _inputUnit.conversion;
              });
            },
          ),
          // Input Unit Dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400],
                width: 1.0,
              )
            ),
            margin: EdgeInsets.only(top: 16.0),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: _getUnitDropdown(_inputUnit.name, _updateInputUnit),
          )
        ],
      )
    );

    // TODO: Create a compare arrows icon.
    var convertArrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    ); 

    // TODO: Create the 'output' group of widgets. This is a Column that
    var outputWidgets = Container(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _format(_outputValue),
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              labelText: 'Output',
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          // Unit Dropdown Selection
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400],
                width: 1.0,
              )
            ),
            margin: EdgeInsets.only(top: 16.0),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: _getUnitDropdown(_outputUnit.name, _updateOutputUnit)
          ),
        ],
      )
    );

    // TODO: Return the input, arrows, and output widgets, wrapped in
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          inputWidgets,
          convertArrows,
          outputWidgets,
        ]
      )
    );
  }

  Widget _getUnitDropdown(String defaultUnit, void onChange(changedValue)) {
    return DropdownButtonHideUnderline(
      child:DropdownButton(
        items: _getUnitDropdownItems(defaultUnit),
        onChanged: onChange, 
        value: defaultUnit,
        style: Theme.of(context).textTheme.headline,
      ),
    );
  }

  List<DropdownMenuItem> _getUnitDropdownItems(String defaultUnit) {
    // Initial dropdown menu item
    var dropdownItems = List<DropdownMenuItem>();

    for (var unit in widget.units) {
      dropdownItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          padding: EdgeInsets.only(left: 8.0, right:8.0),
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }

    return dropdownItems;
  }

  void _updateOutputUnit(var changedValue) {
    setState( () {
      var newOutputUnit = _getUnitByName(changedValue); 
      _outputUnit = newOutputUnit;
      _outputValue = _inputValue * _outputUnit.conversion / _inputUnit.conversion;
    });
  }

  void _updateInputUnit(var changedValue) {
    setState( () {
      var newInputUnit = _getUnitByName(changedValue); 
      _inputUnit = newInputUnit;
      _outputValue = _inputValue * _outputUnit.conversion / _inputUnit.conversion;
    });
  }

  Unit _getUnitByName(String unitName) {
    return widget.units.firstWhere(
      // bool test(Unit unit)
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }
}

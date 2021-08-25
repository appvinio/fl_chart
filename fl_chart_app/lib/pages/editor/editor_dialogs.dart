import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart_app/pages/widgets/color_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

Future<ScatterSpot> showScatterSpotDialog(BuildContext context, ScatterSpot spot) async {
  final newScatterSpot = await showDialog<ScatterSpot>(
    context: context,
    builder: (BuildContext context) {
      return ScatterSpotEditorDialog(
        data: spot,
      );
    },
  );

  if (newScatterSpot == null) {
    throw StateError('newScatterSpot must not be null');
  }

  return newScatterSpot;
}

class ScatterSpotEditorDialog extends StatefulWidget {
  final ScatterSpot data;

  const ScatterSpotEditorDialog({Key? key, required this.data}) : super(key: key);

  @override
  _ScatterSpotEditorDialogState createState() => _ScatterSpotEditorDialogState();
}

class _ScatterSpotEditorDialogState extends State<ScatterSpotEditorDialog> {
  late Color _showingColor;
  late TextEditingController _xController, _yController, _radiusController;

  @override
  void initState() {
    _showingColor = widget.data.color;
    _xController = TextEditingController(text: widget.data.x.toString());
    _yController = TextEditingController(text: widget.data.y.toString());
    _radiusController = TextEditingController(text: widget.data.radius.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('ScatterSpot'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('x: '),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _xController,
                  )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('y: '),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _yController,
                  )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('radius: '),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _radiusController,
                  )),
                ],
              ),
              SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('color: '),
                  SizedBox(
                    width: 8,
                  ),
                  ColorIndicator(
                    color: _showingColor,
                    onChanged: (newColor) {
                      setState(() {
                        _showingColor = newColor;
                      });
                    },
                  )
                ],
              ),
              TextButton(
                  onPressed: () {
                    double newXValue;
                    try {
                      newXValue = double.parse(_xController.text);
                    } catch (e) {
                      return;
                    }

                    double newYValue;
                    try {
                      newYValue = double.parse(_yController.text);
                    } catch (e) {
                      return;
                    }

                    double newRadius;
                    try {
                      newRadius = double.parse(_radiusController.text);
                    } catch (e) {
                      return;
                    }

                    final newScatterSpot = widget.data.copyWith(
                      x: newXValue,
                      y: newYValue,
                      color: _showingColor,
                      radius: newRadius,
                    );

                    Navigator.of(context).pop(newScatterSpot);
                  },
                  child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _radiusController.dispose();
    super.dispose();
  }
}

Future<Color> showColorPickerDialog(BuildContext context, {Color defaultColor = Colors.black}) async {
  final color = await showDialog<Color>(
    context: context,
    builder: (context) {
      return ColorPickerDialog(defaultColor: defaultColor);
    },
  );

  if (color == null) {
    throw StateError('Result color must not be null');
  }

  return color;
}

class ColorPickerDialog extends StatefulWidget {
  final Color defaultColor;

  const ColorPickerDialog({Key? key, required this.defaultColor}) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _showingColor;

  @override
  void initState() {
    super.initState();
    _showingColor = widget.defaultColor;
  }

  // ValueChanged<Color> callback
  void _changeColor(Color color) {
    setState(() => _showingColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: MaterialColorPicker(onColorChange: _changeColor, selectedColor: _showingColor),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: pickerColor,
        //   onColorChanged: changeColor,
        //   showLabel: true, // only on portrait mode
        // ),
        //
        // Use Block color picker:
        //
        // child: BlockPicker(
        //   pickerColor: currentColor,
        //   onColorChanged: changeColor,
        // ),
        //
        // child: MultipleChoiceBlockPicker(
        //   pickerColors: currentColors,
        //   onColorsChanged: changeColors,
        // ),
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Got it'),
          onPressed: () {
            Navigator.of(context).pop(_showingColor);
          },
        ),
      ],
    );
  }
}

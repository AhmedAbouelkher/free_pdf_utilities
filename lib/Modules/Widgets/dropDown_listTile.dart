import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/app_theme.dart';

class DropDownListTile<T> extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;

  final List<DropdownMenuItem<T>> options;
  final TextStyle? optionTitleStyle;
  final T initialValue;
  final ValueChanged<T>? onChanged;

  final bool enabled;

  const DropDownListTile({
    Key? key,
    required this.title,
    this.titleStyle,
    required this.options,
    this.optionTitleStyle,
    required this.initialValue,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);
  @override
  _DropDownListTileState<T> createState() => _DropDownListTileState<T>();
}

class _DropDownListTileState<T> extends State<DropDownListTile<T>> {
  T? _value;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DropDownListTile<T> oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _value = widget.initialValue;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 13,
            color: widget.enabled ? null : Colors.white60,
          ).merge(widget.titleStyle),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: !widget.enabled
                ? themed(
                    context,
                    dark: null,
                    light: Colors.grey[400],
                  )
                : themed(
                    context,
                    dark: Colors.black54,
                    light: Colors.grey,
                  ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: DropdownButton<T>(
              underline: Container(),
              isDense: true,
              value: _value,
              iconSize: 18,
              iconEnabledColor: themed(context, dark: null, light: Colors.white),
              dropdownColor: themed(context, dark: null, light: Colors.grey),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: widget.enabled ? null : Colors.white60,
              ).merge(widget.optionTitleStyle),
              items: widget.options,
              onChanged: (value) {
                if (value == null) return;
                if (widget.onChanged != null) widget.onChanged!(value);
                setState(() => _value = value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

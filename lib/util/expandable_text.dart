import 'package:flutter/material.dart';
import 'package:linkwell/linkwell.dart';
import '/util/ui_helpers.dart';
import '../adaptive/adaptive_theme.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLength;
  final bool useLinkWell;
  ExpandableText(this.text, this.maxLength, this.useLinkWell);

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  bool _isExpanded = false;
  bool _showLess = true;

  @override
  Widget build(BuildContext context) {
    if (widget.text.length < widget.maxLength) {
      _isExpanded = true;
      _showLess = false;
    }
    TextStyle _style = TextStyle(fontSize: textScale(context) <= 1.0 ? 14 : 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: ConstrainedBox(
            constraints: _isExpanded
                ? BoxConstraints()
                : BoxConstraints(maxHeight: 45.0),
            child: widget.useLinkWell
                ? LinkWell(
                    widget.text.trim(),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.fade,
                    linkStyle: _style,
                  )
                : Text(
                    widget.text.trim(),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.fade,
                  ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _isExpanded
                ? _showLess
                    ? TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent),
                        child: Text(
                          'Show Less...',
                          style: TextStyle(
                              fontSize: textScale(context) <= 1.0 ? 14 : 11,
                              letterSpacing: 0.0,
                              color: AdaptiveTheme.primaryColor(context)),
                        ),
                        onPressed: () => setState(() => _isExpanded = false),
                      )
                    : Container()
                : TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent),
                    child: Text(
                      'Show More...',
                      style: TextStyle(
                          fontSize: textScale(context) <= 1.0 ? 14 : 11,
                          letterSpacing: 0.0,
                          color: AdaptiveTheme.primaryColor(context)),
                    ),
                    onPressed: () => setState(() {
                      _isExpanded = true;
                    }),
                  )
          ],
        )
      ],
    );
  }
}

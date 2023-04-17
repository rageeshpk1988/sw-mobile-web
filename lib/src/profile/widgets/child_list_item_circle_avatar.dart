import 'package:flutter/material.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../src/models/child.dart';
import '../../../util/ui_helpers.dart';

class ChildListItemCircleAvatar extends StatefulWidget {
  final Child child;
  final Function addChildHandler;
  final Function removeChildHandler;
  final bool disable;
  ChildListItemCircleAvatar(
    this.child,
    this.addChildHandler,
    this.removeChildHandler,
    this.disable,
  );

  @override
  State<ChildListItemCircleAvatar> createState() =>
      _ChildListItemCircleAvatarState();
}

class _ChildListItemCircleAvatarState extends State<ChildListItemCircleAvatar> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    var name = widget.child.name.split(' ')[0];
    bool showEllipsis = false;
    if (name.length > 7) {
      showEllipsis = true;
    }

    return GestureDetector(
      onTap: widget.disable
          ? null
          : () {
              setState(() {
                _isSelected = !_isSelected;
                if (_isSelected) {
                  widget.addChildHandler(widget.child);
                } else {
                  widget.removeChildHandler(widget.child);
                }
              });

              //call function handler
            },
      child: Container(
        height: 80,
        child: Stack(
          children: <Widget>[
            getAvatarImage(widget.child.imageUrl, 60, 60, BoxShape.circle,
                widget.child.name),
            Positioned(
              bottom: 0,
              left: 10,
              child: Container(
                width: 50,
                child: Text(name,
                    overflow: showEllipsis ? TextOverflow.ellipsis : null,
                    softWrap: true,
                    style: TextStyle(fontSize: 13)),
              ),
            ),
            if (_isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Icon(
                    Icons.check_circle_outline_outlined,
                    color: AdaptiveTheme.primaryColor(context),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

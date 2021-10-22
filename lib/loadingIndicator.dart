import 'package:flutter/material.dart';

class FutureLoader<T> extends PopupRoute<T> {
  final Future<T> completion;
  FutureLoader(this.completion);
  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    completion.then((value) => Navigator.of(context).pop<T>(value));
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Center(
        child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Color.fromRGBO(220, 220, 220, 0.5),
              border: Border.all(width: 0.6),
              borderRadius: BorderRadius.circular(9),
            ),
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(50, 30, 200, 1)),
                    strokeWidth: 2.6,
                  ))),
            )),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}

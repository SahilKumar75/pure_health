import 'package:flutter/cupertino.dart';

class CupertinoLoader extends StatelessWidget {
  final double size;

  const CupertinoLoader({Key? key, this.size = 32}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(radius: size / 2),
    );
  }
}

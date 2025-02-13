import 'package:flutter/material.dart';

class CardDataFinances extends StatelessWidget {
  const CardDataFinances({
    super.key,
    required this.snapshot,
    required this.title,
  });

  final AsyncSnapshot<dynamic> snapshot;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$title ${snapshot.data}'),
      ),
    );
  }
}

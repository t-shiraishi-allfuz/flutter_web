import 'package:flutter/material.dart';

class DmlistWidget extends StatefulWidget {
	DmlistWidget({super.key});

	@override
	_DmlistWidgetState createState() => _DmlistWidgetState();
}

class _DmlistWidgetState extends State<DmlistWidget> {
	@override
	Widget build(BuildContext context) {
		return ListTile(
			leading: CircleAvatar(
				backgroundImage: NetworkImage('https://via.placeholder.com/40'),
			),
			title: Text(
				"ユーザー名",
				style: TextStyle(
					fontWeight: FontWeight.bold,
					color: Colors.white,
				),
			),
			subtitle: Text(
				'DMの内容がここに表示されます。',
				style: TextStyle(color: Colors.white70),
			),
			onTap: () {},
		);
	}
}

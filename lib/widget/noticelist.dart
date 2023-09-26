import 'package:flutter/material.dart';

class NoticelistWidget extends StatefulWidget {
	NoticelistWidget({super.key});

	@override
	_NoticelistWidgetState createState() => _NoticelistWidgetState();
}

class _NoticelistWidgetState extends State<NoticelistWidget> {
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
				'ツイートの内容がここに表示されます。',
				style: TextStyle(
					color: Colors.white70,
				),
			),
		);
	}
}

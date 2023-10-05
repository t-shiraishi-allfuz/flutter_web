import 'package:flutter/material.dart';

class SearchlistWidget extends StatefulWidget {
	SearchlistWidget({super.key});

	@override
	_SearchlistWidgetState createState() => _SearchlistWidgetState();
}

class _SearchlistWidgetState extends State<SearchlistWidget> {
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
				style: TextStyle(color: Colors.white70),
			),
			trailing: ElevatedButton(
				style: ElevatedButton.styleFrom(
					primary: Colors.white,
				),
				child: Text(
					"フォロー",
					style: TextStyle(color: Colors.black),
				),
				onPressed: () {},
			),
		);
	}
}

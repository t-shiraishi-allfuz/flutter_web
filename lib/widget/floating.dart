import 'package:flutter/material.dart';

import './dialog.dart';

class FloatingPostWidget extends StatelessWidget {
	final String uid;

	const FloatingPostWidget({
		required this.uid,
	});

	@override
	Widget build(BuildContext context) {
		return FloatingActionButton(
			onPressed: () {
				PostDialogWidget dialog = PostDialogWidget(
					uid: uid,
					is_reply: false,
					is_quote: false,
				);
				dialog.showInputDialog(context);
			},
			child: Icon(
				Icons.post_add,
				color: Colors.white,
			),
			backgroundColor: Colors.lightBlue,
			shape: StadiumBorder(),
		);
	}
}
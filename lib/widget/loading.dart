import 'package:flutter/material.dart';

// 読み込み中widget
class LoadingWidget extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Container(
			color: Colors.black87,
			child: Center(
				child: CircularProgressIndicator(
					valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
				),
			),
		);
	}
}

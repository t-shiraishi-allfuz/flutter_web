import 'package:flutter/material.dart';

// 汎用ウィジェット
// フォローされてます表示
class showFollowerWidget extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return ClipRRect(
			borderRadius: BorderRadius.all(Radius.circular(5)),
			child: Container(
				color: Colors.black54,
				child: Padding(
					padding: EdgeInsets.all(2.0),
					child: Text(
						"フォローされています",
						style: TextStyle(
							color: Colors.white54,
							fontSize: 10,
						),
					),
				),
			),
		);
	}
}

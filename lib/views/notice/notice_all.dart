import 'package:flutter/material.dart';

import '../../widget/noticelist.dart';

class NoticeAllScreen extends StatefulWidget {
	final String uid;

	NoticeAllScreen({required this.uid});

	@override
	State<NoticeAllScreen> createState() => _NoticeAllScreenState();
}

class _NoticeAllScreenState extends State<NoticeAllScreen> {
	late String uid;

	@override
	void initState() {
		super.initState();
		uid = widget.uid;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.transparent,
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						Expanded(
							child: ListView.builder(
								itemCount: 10,
								itemBuilder: (context, index) {
									return NoticelistWidget();
								},
							),
						),
					],
				),
			),
		);
	}
}

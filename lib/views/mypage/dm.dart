import 'package:flutter/material.dart';

import '../../widget/dmlist.dart';

class DmScreen extends StatefulWidget {
	final String uid;

	DmScreen({required this.uid});

	@override
	State<DmScreen> createState() => _DmScreen();
}

class _DmScreen extends State<DmScreen> {
	late String uid;

	@override
	void initState() {
		super.initState();
		uid = widget.uid;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				automaticallyImplyLeading: false,
				title: Text(
					"メッセージ",
					style: TextStyle(color: Colors.white),
				),
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						Expanded(
							child: ListView.builder(
								itemCount: 10,
								itemBuilder: (context, index) {
									return DmlistWidget();
								},
							),
						),
					],
				),
			),
		);
	}
}

import 'package:flutter/material.dart';

import '../widget/searchlist.dart';

class SearchAllScreen extends StatefulWidget {
	const SearchAllScreen({super.key});

	@override
	State<SearchAllScreen> createState() => _SearchAllScreenState();
}

class _SearchAllScreenState extends State<SearchAllScreen> {
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
									return SearchlistWidget();
								},
							),
						),
					],
				),
			),
		);
	}
}

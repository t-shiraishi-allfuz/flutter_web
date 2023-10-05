import 'package:flutter/material.dart';

import '../../widget/searchlist.dart';

class SearchTrendScreen extends StatefulWidget {
	const SearchTrendScreen({super.key});

	@override
	State<SearchTrendScreen> createState() => _SearchTrendScreenState();
}

class _SearchTrendScreenState extends State<SearchTrendScreen> {
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

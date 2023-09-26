import 'package:flutter/material.dart';

import 'search_all.dart';
import 'search_trend.dart';

class SearchScreen extends StatefulWidget {
	SearchScreen({super.key});

	@override
	State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> with TickerProviderStateMixin {
	late TabController _headerController;

	@override
	void initState() {
		super.initState();
		_headerController = TabController(length: 2, vsync: this);
	}

	@override
	void dispose() {
		_headerController.dispose();
		super.dispose();
	}

	List<Widget> _headerTab = [
		Tab(child: Text("おすすめ"),),
		Tab(child: Text("トレンド"),),
	];

	List<Widget> _headerBuildTabPages() {
		return [
			SearchAllScreen(),
			SearchTrendScreen(),
		];
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				toolbarHeight: 80.0,
				automaticallyImplyLeading: false,
				title: Padding(
					padding: EdgeInsets.all(10.0),
					child: TextFormField(
						decoration: InputDecoration(
							labelText: "検索",
							hintText: "キーワードを入力して下さい",
							prefixIcon: Icon(Icons.search),
							filled: true,
							fillColor: Colors.black54,
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(30.0),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(30.0),
								borderSide: BorderSide(
									color: Colors.lightBlue,
								),
							),
							labelStyle: TextStyle(
								color: Colors.grey,
							),
						),
						cursorColor: Colors.lightBlue,
					),
				),
			),
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						child: TabBar(
							controller: _headerController,
							tabs: _headerTab,
							labelColor: Colors.white,
							indicatorColor: Colors.lightBlue,
							unselectedLabelColor: Colors.grey[600],
						),
					),
					Expanded(
						child: TabBarView(
							physics: NeverScrollableScrollPhysics(),
							controller: _headerController,
							children: _headerBuildTabPages(),
						),
					),
				],
			),
		);
	}
}

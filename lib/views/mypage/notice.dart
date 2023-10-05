import 'package:flutter/material.dart';

import '../notice/notice_all.dart';
import '../notice/notice_reply.dart';

class NoticeScreen extends StatefulWidget {
	final String uid;

	NoticeScreen({required this.uid});

	@override
	State<NoticeScreen> createState() => _NoticeScreen();
}

class _NoticeScreen extends State<NoticeScreen> with TickerProviderStateMixin {
	late TabController _headerController;
	late String uid;

	@override
	void initState() {
		super.initState();
		_headerController = TabController(length: 2, vsync: this);
		uid = widget.uid;
	}

	@override
	void dispose() {
		_headerController.dispose();
		super.dispose();
	}

	List<Widget> _headerTab = [
		Tab(child: Text("おすすめ"),),
		Tab(child: Text("返信"),),
	];

	List<Widget> _headerBuildTabPages() {
		return [
			NoticeAllScreen(uid: uid),
			NoticeReplyScreen(uid: uid),
		];
	}

	@override
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				automaticallyImplyLeading: false,
				title: Text(
					"通知",
					style: TextStyle(color: Colors.white),
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

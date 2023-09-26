import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../login.dart';
import '../model/post.dart';
import '../model/profile.dart';
import 'timeline_all.dart';
import 'timeline_follow.dart';
import '../utils/media_uploader.dart';
import '../widget/user.dart';
import '../widget/floating.dart';
import '../widget/dialog.dart';

class HomeScreen extends StatefulWidget {
	final ProfileModel profile;

	HomeScreen({required this.profile});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
	late TabController _headerController;
	late ProfileModel profile;

	@override
	void initState() {
		super.initState();
		_headerController = TabController(length: 2, vsync: this);
		profile = widget.profile;
	}

	@override
	void dispose() {
		_headerController.dispose();
		super.dispose();
	}

	List<Widget> _headerTab = [
		Tab(child: Text("おすすめ"),),
		Tab(child: Text("フォロー中"),),
	];

	List<Widget> _headerBuildTabPages() {
		return [
			TimelineAll(uid: profile.uid),
			TimelineFollow(uid: profile.uid),
		];
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				automaticallyImplyLeading: false,
				leading: IconButton(
					icon: UserIconWidget(
						profile: profile,
						is_edit: false,
						uid: profile.uid
					),
					onPressed: () {
						Navigator.pushNamed(
							context,
							"/profile",
							arguments: {
								"uid": profile.uid,
								"is_self": true
							}
						);
					},
				),
				title: const Text(
					"ホーム",
					style: TextStyle(
						color: Colors.white
					),
				),
				actions: [
					IconButton(
						icon: Icon(Icons.menu),
						color: Colors.white,
						onPressed: () {
							_showMenuDialog(context);
						},
					),
				],
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
			floatingActionButton: FloatingPostWidget(uid: profile.uid),
			floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
		);
	}

	// メニューダイアログ
	void _showMenuDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return SimpleDialog(
					backgroundColor: Colors.black87,
					shape: RoundedRectangleBorder(
						side: BorderSide(
							color: Colors.white70,
						),
						borderRadius: BorderRadius.circular(10.0),
					),
					shadowColor: Colors.white70,
					children: [
						SimpleDialogOption(
							child: Row(
								children: [
									Icon(
										Icons.settings,
										color: Colors.white,
									),
									SizedBox(width: 5.0),
									Text(
										"設定",
										style: TextStyle(
											color: Colors.white,
										),
									),
								],
							),
							onPressed: () {
								Navigator.of(context).pop();
							},
						),
						SimpleDialogOption(
							child: Row(
								children: [
									Icon(
										Icons.logout,
										color: Colors.white,
									),
									SizedBox(width: 5.0),
									Text(
										"ログアウト",
										style: TextStyle(
											color: Colors.white,
										),
									),
								],
							),
							onPressed: () {
								Navigator.of(context).pop();
								LogoutDialogWidget();
							},
						),
					],
				);
			}
		);
	}
}

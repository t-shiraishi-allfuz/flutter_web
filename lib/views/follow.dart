import 'package:flutter/material.dart';

import './follow/follow_list.dart';
import './follow/follower_list.dart';

import '../model/profile.dart';
import '../model/profile_merge.dart';
import '../utils/custom_shared.dart';
import '../widget/loading.dart';

// フォロー・フォロワー一覧
class Follow extends StatefulWidget {
	final Map<String, dynamic> arguments;

	Follow({required this.arguments});

	@override
	State<Follow> createState() => _Follow();
}

class _Follow extends State<Follow> with TickerProviderStateMixin {
	late TabController _headerController;
	late String uid;
	late bool is_self;
	late Future<ProfileMergeModel> profileFuture;

	@override
	void initState() {
		super.initState();
		_headerController = TabController(length: 2, vsync: this);
		uid = widget.arguments["uid"];
		is_self = widget.arguments["is_self"];
		profileFuture = fetchData();
	}

	@override
	void dispose() {
		_headerController.dispose();
		super.dispose();
	}

	// プロフィール取得
	Future<ProfileMergeModel> fetchData() async {
		// 自分のUIDを取得
		final self_uid = await CustomShared.getUID();

		return await ProfileModel.fetchProfileMergeModel(uid, self_uid!);
	}

	List<Widget> _headerTab = [
		Tab(child: Text("フォロー"),),
		Tab(child: Text("フォロワー"),),
	];

	List<Widget> _headerBuildTabPages() {
		return [
			FollowListScreen(uid: uid, is_self: is_self),
			FollowerListScreen(uid: uid, is_self: is_self),
		];
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<ProfileMergeModel>(
			future: profileFuture,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return LoadingWidget();
				} else if (snapshot.hasError) {
					return Center(child: Text("エラーが発生しました"));
				} else if (snapshot.connectionState == ConnectionState.done) {
					final profile = snapshot.data!;

					return Scaffold(
						appBar: AppBar(
							backgroundColor: Colors.transparent,
							automaticallyImplyLeading: false,
							title: Column(
								children: [
									Text(
										profile.profile.username!,
										style: TextStyle(
											color: Colors.white
										),
									),
									Text(
										"@"+ profile.profile.acount!,
										style: TextStyle(
											color: Colors.white70,
											fontSize: 14,
										),
									),
								],
							),
							leading: IconButton(
								icon: Icon(Icons.arrow_back),
								color: Colors.white,
								onPressed: () async {
									await CustomShared.deleteUri();

									Navigator.pushNamed(
										context,
										"/profile",
										arguments: {"uid": uid, "is_self": is_self}
									);
								},
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
				} else {
					return Container();
				}
			},
		);
	}
}

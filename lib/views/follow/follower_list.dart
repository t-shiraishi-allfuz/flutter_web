import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/profile.dart';
import '../../model/follow.dart';
import '../../model/profile_merge.dart';
import '../../utils/custom_shared.dart';
import '../../utils/profile_manager.dart';
import '../../widget/followlist.dart';
import '../../widget/loading.dart';

// フォロー一覧
class FollowerListScreen extends StatefulWidget {
	final String uid;
	final bool is_self;

	FollowerListScreen({
		required this.uid,
		required this.is_self,
	});

	@override
	State<FollowerListScreen> createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
	late String uid;
	late bool is_self;
	late Future<List<ProfileMergeModel>> profileFuture;

	@override
	void initState() {
		super.initState();
		uid = widget.uid;
		is_self = widget.is_self;
		profileFuture = fetchData();
	}

	// プロフィール取得
	Future<List<ProfileMergeModel>> fetchData() async {
		// 自分のUIDを取得
		final self_uid = await CustomShared.getUID();

		final uids = await FollowModel.getFollowerList(uid);
		return await ProfileModel.getProfileByUids(uids, self_uid!);
	}

	// データ再取得
	void reFetch() {
		profileFuture = fetchData();
	}

	@override
	Widget build(BuildContext context) {
		// 初期化
		ProfileManager profileManager = context.read<ProfileManager>();

		return Scaffold(
			backgroundColor: Colors.transparent,
			body: Consumer<ProfileManager>(
				builder: (context, state, _) {
					if (state.is_change) {
						reFetch();
					}

					return FutureBuilder<List<ProfileMergeModel>>(
						future: profileFuture,
						builder: (context, snapshot) {
							if (snapshot.connectionState == ConnectionState.waiting) {
								return LoadingWidget();
							} else if (snapshot.hasError) {
								return Center(child: Text("エラーが発生しました"));
							} else if (snapshot.connectionState == ConnectionState.done) {
								final profile = snapshot.data!;

								if (profile.isEmpty) {
									return Center(
										child: Text(
											"フォロワーはいません",
											style: TextStyle(color: Colors.white),
										),
									);
								} else {
									return Scaffold(
										backgroundColor: Colors.transparent,
										body: Padding(
											padding: const EdgeInsets.all(16.0),
											child: Column(
												children: [
													Expanded(
														child: ListView.builder(
															itemCount: profile.length,
															itemBuilder: (context, index) {
																return FollowlistWidget(
																	profile: profile[index],
																);
															},
														),
													),
												],
											),
										),
									);
								}
							} else {
								return Container();
							}
						},
					);
				},
			),
		);
	}
}

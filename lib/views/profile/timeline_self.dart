import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/post.dart';
import '../../model/post_merge.dart';
import '../../utils/post_manager.dart';
import '../../widget/timeline.dart';
import '../../widget/loading.dart';

class TimelineSelfScreen extends StatefulWidget {
	final String uid;

	TimelineSelfScreen({required this.uid});

	@override
	State<TimelineSelfScreen> createState() => _TimelineSelfScreen();
}

class _TimelineSelfScreen extends State<TimelineSelfScreen> with AutomaticKeepAliveClientMixin {
	late String uid;
	late Future<List<PostMergeModel>> postsFuture;

	@override
	bool get wantKeepAlive => true;

	@override
	void initState() {
		super.initState();
		uid = widget.uid;
		postsFuture = fetchData();
	}

	// データ取得
	Future<List<PostMergeModel>> fetchData() async {
		return await PostModel.getPostByUid(uid);
	}

	// データ再取得
	void reFetch() {
		postsFuture = fetchData();
	}

	@override
	Widget build(BuildContext context) {
		// 初期化
		PostManager postManager = context.read<PostManager>();

		return Scaffold(
			backgroundColor: Colors.transparent,
			body: Consumer<PostManager>(
				builder: (context, state, _) {
					if (state.is_change) {
						reFetch();
					}

					return FutureBuilder<List<PostMergeModel>>(
						future: postsFuture,
						builder: (context, snapshot) {
							if (snapshot.connectionState == ConnectionState.waiting) {
								return LoadingWidget();
							} else if (snapshot.hasError) {		
								return Center(
									child: Text(
										"エラーが発生しました",
										style: TextStyle(color: Colors.red),
									),
								);	
							} else if (snapshot.hasData && snapshot.data != null) {
								final posts = snapshot.data!;

								if (posts.isEmpty) {
									return Center(
										child: Text(
											"投稿はありません",
											style: TextStyle(color: Colors.white),
										),
									);
								} else {
									return TimelineWidget(
										posts: posts,
										uid: uid,
									);
								}
							} else {
								// 通らないけど警告になるので
								return Container();
							}
						},
					);
				},
			),
		);
	}
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/post.dart';
import '../model/post_merge.dart';
import '../utils/post_manager.dart';
import '../utils/custom_shared.dart';
import '../widget/loading.dart';
import '../widget/timeline.dart';

class PostDetail extends StatefulWidget {
	final Map<String, dynamic> arguments;

	PostDetail({required this.arguments});

	@override
	State<PostDetail> createState() => _PostDetail();
}

class _PostDetail extends State<PostDetail> {
	late String post_id;
	late String uid;
	late Future<List<PostMergeModel>> postsFuture;
	late Future<List<PostMergeModel>> replyFuture;

	@override
	void initState() {
		super.initState();

		post_id = widget.arguments["post_id"];
		uid = widget.arguments["uid"];
		postsFuture = fetchData();
		replyFuture = fetchReplyData();
	}

	// データ取得
	Future<List<PostMergeModel>> fetchData() async {
		return await PostModel.getPostById(post_id, uid);
	}

	// データ取得
	Future<List<PostMergeModel>> fetchReplyData() async {
		return await PostModel.getReplyAll(uid, post_id);
	}

	// データ再取得
	void reFetch() {
		postsFuture = fetchData();
		replyFuture = fetchReplyData();
	}

	@override
	Widget build(BuildContext context) {
		// 初期化
		PostManager postManager = context.read<PostManager>();

		ModalRoute? currentRoute = ModalRoute.of(context);
		String? routeName;
		if (currentRoute != null) {
			routeName = currentRoute.settings.name!;
		}

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				toolbarHeight: 50.0,
				title: Text(
					"投稿する",
					style: TextStyle(
						color: Colors.white,
					),
				),
				leading: IconButton(
					icon: Icon(Icons.arrow_back),
					color: Colors.white,
					onPressed: () async {
						await CustomShared.deleteUri();

						if (routeName == "/detail") {
							Navigator.pushNamed(
								context,
								"/mypage"
							);
						} else {
							Navigator.pushNamed(
								context,
								"/profile",
								arguments: {"uid": uid}
							);
						}
					},
				),
			),
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
										style: TextStyle(
											color: Colors.red
										),
									),
								);	
							} else if (snapshot.hasData && snapshot.data != null) {
								final posts = snapshot.data!;

								if (posts.isEmpty) {
									return Center(
										child: Text(
											"投稿はありません",
											style: TextStyle(
												color: Colors.white
											),
										),
									);
								} else {
									return Timeline(
										posts: posts,
										uid: uid,
										replyFuture: replyFuture,
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

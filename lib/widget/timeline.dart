import 'package:flutter/material.dart';

import '../model/post_merge.dart';
import '../widget/postcard.dart';

class TimelineWidget extends StatefulWidget {
	List<PostMergeModel> posts;
	final String uid;
	Future<List<PostMergeModel>>? replyFuture; 

	TimelineWidget({
		required this.posts,
		required this.uid,
		this.replyFuture
	});

	@override
	_TimelineWidget createState() => _TimelineWidget();
}

class _TimelineWidget extends State<TimelineWidget> {
	late List<PostMergeModel> posts;
	late String uid;
	late Future<List<PostMergeModel>>? replyFuture;

	@override
	void initState() {
		super.initState();
		posts = widget.posts;
		uid = widget.uid;
		replyFuture = widget.replyFuture;
	}

	@override
	Widget build(BuildContext context) {
		return ListView.builder(
			itemCount: widget.posts.length,
			itemBuilder: (context, index) {
				return Column(
					children: [
						PostCardWidget(post: posts[index], uid: uid),
						Divider(height: 1.0),
						if (replyFuture != null)
							FutureBuilder<List<PostMergeModel>>(
								future: replyFuture,
								builder: (context, snapshot) {
									if (snapshot.connectionState == ConnectionState.waiting) {
										return SizedBox();
									} else if (snapshot.hasError) {	
										return Center(
											child: Text(
												"エラーが発生しました",
												style: TextStyle(color: Colors.red),
											),
										);
									} else if (snapshot.hasData && snapshot.data != null) {
										final replys = snapshot.data!;

										if (posts.isEmpty) {
											return Center(
												child: Text(
													"投稿はありません",
													style: TextStyle(color: Colors.white),
												),
											);
										} else {
											return Column(
												children: [
													PostCardWidget(post: replys[index], uid: uid),
													Divider(height: 1.0),
												],
											);
										}
									} else {
										// 通らないけどエラーになる
										return Container();
									}
								}
							),
					],
				);
			},
		);
	}
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/post.dart';
import '../model/like.dart';
import '../model/post_merge.dart';
import '../utils/custom_shared.dart';
import '../utils/post_manager.dart';
import '../utils/profile_manager.dart';
import '../widget/user.dart';
import '../widget/loading.dart';
import '../widget/dialog.dart';

class PostCardWidget extends StatefulWidget {
	PostMergeModel post;
	final String uid;

	PostCardWidget({
		required this.post,
		required this.uid,
	});

	@override
	_PostCardWidget createState() => _PostCardWidget();
}

class _PostCardWidget extends State<PostCardWidget> {
	late PostMergeModel post;
	late String uid;

	@override
	void initState() {
		super.initState();

		post = widget.post;
		uid = widget.uid;
	}

	// 再投稿
	Future<void> addRepost(PostMergeModel post) async {
		PostManager manager = PostManager();
		await manager.addRepost(uid, null, null, post, false);
	}

	// いいね
	Future<void> addLike(PostMergeModel post) async {
		PostManager manager = PostManager();
		await manager.addLike(uid, post);
	}

	// 投稿削除
	Future<void> deletePost(PostMergeModel post) async {
		PostManager manager = PostManager();
		await manager.deletePost(uid, post);
	}

	// フォロー更新
	Future<void> changeFollow(PostMergeModel post) async {
		ProfileManager manager = ProfileManager();

		if (post.is_follow) {
			await manager.deleteFollow(uid, post.post.uid);
		} else {
			await manager.executeFollow(uid, post.post.uid);
		}
	}

	@override
	Widget build(BuildContext context) {
		PostManager postManager = context.read<PostManager>();

		ModalRoute? currentRoute = ModalRoute.of(context);
		String? routeName;
		if (currentRoute != null) {
			routeName = currentRoute.settings.name!;
		}

		return Container(
			width: double.infinity,
			child: Padding(
				padding: EdgeInsets.all(16.0),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Align(
									alignment: Alignment.topLeft,
									child: UserIconWidget(
										profile: post.profile,
										is_edit: false,
										uid: uid
									),
								),
								SizedBox(width: 10.0),
								Expanded(
									child: Column(
										mainAxisAlignment: MainAxisAlignment.start,
										children: [
											Container(
												child: GestureDetector(
													onTap: () {
														// 投稿詳細以外では詳細に遷移させる
														if (routeName != null && routeName != "/detail") {
															Navigator.pushNamed(
																context,
																"/detail",
																arguments: {
																	"post_id": post.post.id,
																	"uid": post.post.uid,
																}
															);
														}
													},
													child: Column(
														mainAxisAlignment: MainAxisAlignment.start,
														children: [
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	UserNameWidget(post: post, type: "1"),
																	Expanded(
																		child: Align(
																			alignment: Alignment.topRight,
																			child: IconButton(
																				icon: Icon(Icons.more_vert),
																				color: Colors.white70,
																				onPressed: () {
																					_showMenuDialog(context, routeName);
																				},
																			),
																		),
																	),
																],
															),
															SizedBox(height: 8.0),
															Align(
																alignment: Alignment.topLeft,
																child: Text(
																	post.post.content,
																	style: TextStyle(color: Colors.white),
																),
															),
															SizedBox(height: 8.0),
															GetMediafileWidget(post: post.post),
														],
													),
												),
											),
											SizedBox(height: 10.0),
											if (post.repost != null && post.is_quote != false)
												ClipRect(
													child: Container(
														width: double.infinity,
														decoration: BoxDecoration(
															border: Border.all(color: Colors.white70, width: 1),
															borderRadius: BorderRadius.circular(10),
														),
														child: Padding(
															padding: EdgeInsets.all(16.0),
															child: Column(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Row(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Align(
																				alignment: Alignment.topLeft,
																				child: UserIconWidget(
																					profile: post.repost!.profile,
																					is_edit: false,
																					uid: uid
																				),
																			),
																			SizedBox(width: 10.0),
																			Expanded(
																				child: UserNameWidget(post: post, type: "2"),
																			),
																		],
																	),
																	SizedBox(height: 8.0),
																	Align(
																		alignment: Alignment.topLeft,
																		child: Text(
																			post.repost!.post!.content,
																			style: TextStyle(color: Colors.white),
																		),
																	),
																	SizedBox(height: 8.0),
																	GetMediafileWidget(post: post.repost!.post!),
																],
															),
														),
													)
												),
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													Row(
														children: [
															IconButton(
																icon: Icon(Icons.comment),
																color: Colors.white70,
																onPressed: () {
																	PostDialogWidget dialog = PostDialogWidget(
																		uid: uid,
																		is_reply: true,
																		is_quote: false,
																		post: post
																	);
																	dialog.showInputDialog(context);
																},
															),
															SizedBox(width: 4.0),
															Text(post.reply_count, style: TextStyle(fontSize: 12, color: Colors.white70)),
														],
													),
													Row(
														children: [
															IconButton(
																icon: Icon(Icons.repeat),
																color: (post.is_repost) ? Colors.pink : Colors.white70,
																onPressed: () {
																	_showRepostDialog(context);
																},
															),
															SizedBox(width: 4.0),
															Text(post.repost_count, style: TextStyle(fontSize: 12, color: Colors.white70)),
														],
													),
													Row(
														children: [
															IconButton(
																icon: (post.is_like) ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
																color: (post.is_like) ? Colors.pink : Colors.white70,
																onPressed: () async {
																	await addLike(post);
																	postManager.fetchData();
																},
															),
															SizedBox(width: 4.0),
															Text(post.like_count, style: TextStyle(fontSize: 12, color: Colors.white70)),
														],
													),
												],
											),
										],
									),
								),
							],
						),
					],
				),
			),
		);
	}

	// 再投稿ダイアログ
	void _showRepostDialog(BuildContext context) {
		PostManager postManager = context.read<PostManager>();

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
										Icons.repeat,
										color: Colors.white,
									),
									SizedBox(width: 5.0),
									Text(
										"再投稿",
										style: TextStyle(color: Colors.white),
									),
								],
							),
							onPressed: () async {
								await addRepost(post);
								postManager.fetchData();
								Navigator.of(context).pop();
							},
						),
						SimpleDialogOption(
							child: Row(
								children: [
									Icon(
										Icons.drive_file_rename_outline,
										color: Colors.white,
									),
									SizedBox(width: 5.0),
									Text(
										"引用",
										style: TextStyle(color: Colors.white),
									),
								],
							),
							onPressed: () {
								Navigator.of(context).pop();

								PostDialogWidget dialog = PostDialogWidget(
									uid: uid,
									is_reply: false,
									is_quote: true,
									post: post
								);
								dialog.showInputDialog(context);
							},
						),
					],
				);
			}
		);
	}

	// メニューダイアログ
	void _showMenuDialog(BuildContext context, String? routeName) {
		PostManager postManager = context.read<PostManager>();

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
						if (post.is_self == false && post.is_follow)
							SimpleDialogOption(
								child: Row(
									children: [
										Icon(
											Icons.person_off,
											color: Colors.white,
										),
										SizedBox(width: 5.0),
										Text(
											"フォローを解除",
											style: TextStyle(color: Colors.white),
										),
									],
								),
								onPressed: () async {
									await changeFollow(post);
									postManager.fetchData();
									Navigator.of(context).pop();
								},
							),
						if (post.is_self == false && post.is_follow == false)
							SimpleDialogOption(
								child: Row(
									children: [
										Icon(
											Icons.person_add,
											color: Colors.white,
										),
										SizedBox(width: 5.0),
										Text(
											"フォローする",
											style: TextStyle(color: Colors.white),
										),
									],
								),
								onPressed: () async {
									await changeFollow(post);
									postManager.fetchData();
									Navigator.of(context).pop();
								},
							),
						if (post.is_self)
							SimpleDialogOption(
								child: Row(
									children: [
										Icon(
											Icons.delete,
											color: Colors.white,
										),
										SizedBox(width: 5.0),
										Text(
											"投稿を削除",
											style: TextStyle(color: Colors.white),
										),
									],
								),
								onPressed: () async {
									await deletePost(post);
									postManager.fetchData();

									// 詳細画面の場合は、削除後に前の画面に戻す
									if (routeName != null && routeName == "/detail") {
										await CustomShared.deleteUri();

										Navigator.pushNamed(
											context,
											"/mypage"
										);
									} else {
										Navigator.of(context).pop();
									}
								},
							),
					],
				);
			}
		);
	}
}

class GetMediafileWidget extends StatelessWidget {
	PostModel post;

	GetMediafileWidget({required this.post});

	@override
	Widget build(BuildContext context) {
		var _screenSize = MediaQuery.of(context).size;

		if (post.is_media) {
			return Row(
				children: [
					Expanded(
						child: Container(
							width: _screenSize.width * 0.5,
							child: Align(
								alignment: Alignment.topLeft,
								child: ClipRRect(
									borderRadius: BorderRadius.circular(10.0),
									child: Image.network(
										post.mediafile!,
										fit: BoxFit.contain,
									),
								),
							),
						),
					),
					SizedBox(height: 8.0),
				],
			);
		} else {
			return SizedBox(height: 1.0);
		}
	}
}

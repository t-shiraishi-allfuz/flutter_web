import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../views/login.dart';
import '../model/post_merge.dart';
import '../utils/media_uploader.dart';
import '../utils/post_manager.dart';
import '../widget/postcard.dart';
import '../widget/user.dart';

// 投稿ダイアログ
class PostDialogWidget {
	final String uid;
	final bool is_reply;
	final bool is_quote;
	final PostMergeModel? post;
	String? selectImageUrl;
	bool is_save = false;
	TextEditingController _textController = TextEditingController();

	PostDialogWidget({
		required this.uid,
		required this.is_reply,
		required this.is_quote,
		this.post,
	});

	// 投稿
	Future<void> execute(String? text, String? mediafile) async {
		is_save = true;
		PostManager manager = PostManager();
		String? reply_post_id;
		String? repost_post_id;

		// 返信
		if (is_reply != false) {
			reply_post_id = post!.post.id;
		}

		// 引用投稿の場合はRepostも更新
		if (is_quote != false) {
			await manager.addRepost(
				uid,
				text,
				mediafile,
				post!,
				true
			);
			repost_post_id = post!.post.id;
		}
		await manager.executePost(uid, text, mediafile, reply_post_id, repost_post_id);
	}

	// 投稿せずにダイアログを閉じた場合はアップした画像を消す
	Future<void> resetImage() async {
		if (selectImageUrl != null) {
			await MediaUploader.deleteImage(selectImageUrl!);
		}
	}

	// 入力エラーダイアログ
	void showErrorDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					backgroundColor: Colors.black87,
					shape: RoundedRectangleBorder(
						side: BorderSide(
							color: Colors.white70,
						),
						borderRadius: BorderRadius.circular(10.0),
					),
					shadowColor: Colors.white70,
					title: Text(
						"入力エラー",
						style: TextStyle(color: Colors.white),
					),
					content: Text(
						"投稿内容が入力されていません",
						style: TextStyle(color: Colors.red),
					),
					actions: [
						TextButton(
							child: Text(
								"閉じる",
								style: TextStyle(color: Colors.lightBlue),
							),
							onPressed: () {
								_textController = TextEditingController();
								Navigator.of(context).pop();
								showInputDialog(context);
							}
						),
					],
				);
			},
		);
	}

	// ダイアログ
	void showInputDialog(BuildContext context) async {
		StreamController<String> _streamController = StreamController<String>();
		PostManager postManager = context.read<PostManager>();

		var _screenSize = MediaQuery.of(context).size;

		// 画像選択
		Future<void> selectImage() async {
			String? newImageUrl = await MediaUploader.pickFile(uid);

			if (newImageUrl != null) {
				selectImageUrl = newImageUrl!;
				_streamController.add(selectImageUrl!);
			}
		}

		final result = await showDialog(
			context: context,
			builder: (BuildContext context) {
				return Dialog(
					backgroundColor: Colors.black87,
					shape: RoundedRectangleBorder(
						side: BorderSide(
							color: Colors.white70,
						),
						borderRadius: BorderRadius.circular(10.0),
					),
					shadowColor: Colors.white70,
					child: ClipRect(
						child: Container(
							width: 600,
							padding: EdgeInsets.all(16),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									Container(
										height: 70,
										child: Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Align(
													alignment: Alignment.topLeft,
													child: GestureDetector(
														onTap: () {
															Navigator.of(context).pop();
														},
														child:Icon(
															Icons.cancel,
															color: Colors.white
														),
													),
												),
												Align(
													alignment: Alignment.topRight,
													child: ElevatedButton(
														onPressed: () async {
															String text = _textController.text;
															Navigator.of(context).pop();
															if (text != "") {
																await execute(text, selectImageUrl);
																postManager.fetchData();
															} else {
																showErrorDialog(context);
															}
														},
														style: ElevatedButton.styleFrom(
															primary: Colors.lightBlue,
														),
														child: Text(
															(is_reply) ? "返信" : "投稿",
															style: TextStyle(color: Colors.white),
														),
													),
												),
											],
										),
									),
									Container(
										child: Column(
											mainAxisSize: MainAxisSize.min,
											children: [
												TextField(
													controller: _textController,
													autofocus: true,
													maxLines: 4,
													maxLength: 200,
													cursorColor: Colors.lightBlue,
													decoration: InputDecoration(
														hintText: (is_reply) ? "返信を投稿する" :" いまどうしてる？",
														hintStyle: TextStyle(color: Colors.grey),
														counterStyle: TextStyle(color: Colors.white70),
														enabledBorder: UnderlineInputBorder(
															borderSide: BorderSide(color: Colors.white70),
														),
														focusedBorder: UnderlineInputBorder(
															borderSide: BorderSide(color: Colors.lightBlue),
														),
													),
													inputFormatters: [
														LengthLimitingTextInputFormatter(200),
													],
													style: TextStyle(color: Colors.white),
												),
												SizedBox(height: 8.0),
												StreamBuilder<String>(
													stream: _streamController.stream,
													builder: (context, snapshot) {
														if (snapshot.hasError) {
															return Container();
														} else {
															switch (snapshot.connectionState) {
																case ConnectionState.none:
																case ConnectionState.waiting:
																case ConnectionState.done:
																	return Container();

																case ConnectionState.active:
																	if (snapshot.hasData) {
																		return Container(
																			height: 200,
																			padding: EdgeInsets.all(10),
																			child: SingleChildScrollView(
																				child: Column(
																					mainAxisSize: MainAxisSize.min,
																					children: [
																						Image.network(
																							snapshot.data!,
																							fit: BoxFit.contain,
																						),
																					],
																				),
																			),
																		);
																	} else {
																		return Container();
																	}
															}
														}
													},
												),
												if (is_reply != false || is_quote != false)
													ClipRect(
														child: Container(
															width: double.infinity,
															padding: EdgeInsets.all(16),
															decoration: BoxDecoration(
																border: Border.all(color: Colors.white70, width: 1),
																borderRadius: BorderRadius.circular(10),
															),
															child: Column(
																mainAxisSize: MainAxisSize.min,
																children: [
																	Row(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Align(
																				alignment: Alignment.topLeft,
																				child: UserIconWidget(
																					profile: post!.profile,
																					is_edit: false,
																					uid: uid
																				),
																			),
																			SizedBox(width: 8.0),
																			UserNameVerticalWidget(post: post!),
																		],
																	),
																	SizedBox(height: 8.0),
																	Align(
																		alignment: Alignment.topLeft,
																		child: Text(
																			post!.post.content,
																			style: TextStyle(color: Colors.white),
																		),
																	),
																	SizedBox(height: 8.0),
																	GetMediafileWidget(post: post!.post),
																],
															),
														),
													),
													SizedBox(height: 8.0),
											],
										),
									),
									Container(
										height: 50,
										child: Row(
											mainAxisAlignment: MainAxisAlignment.start,
											children: [
												Align(
													alignment: Alignment.topLeft,
													child: GestureDetector(
														onTap: () async {
															await selectImage();
														},
														child: Icon(
															Icons.add_photo_alternate,
															color: Colors.lightBlue,
														),
													),
												),
												SizedBox(width: 5.0),
												Align(
													alignment: Alignment.topLeft,
													child: GestureDetector(
														onTap: () {
															showEmojiDialog(context);
														},
														child: Icon(
															Icons.sentiment_satisfied_alt,
															color: Colors.lightBlue,
														),
													),
												),
											],
										),
									),
								],
							),
						),
					),
				);
			},
		).then((value) {
			_textController.clear();

			if (is_save == false) {
				resetImage();
			} 
		});

		_streamController.close();
		_textController.dispose();
	}

	void showEmojiDialog(BuildContext context) {
		_onBackspacePressed() {
			_textController
				..text = _textController.text.characters.toString()
				..selection = TextSelection.fromPosition(
					TextPosition(offset: _textController.text.length));
		}

		showModalBottomSheet(
			context: context,
			isScrollControlled: false,
			enableDrag: false,
			builder: (BuildContext context) {
				return SizedBox(
					height: 400,
					child: EmojiPicker(
						textEditingController: _textController,
						onBackspacePressed: _onBackspacePressed,
						config: Config(
							emojiSizeMax: 24,
							bgColor: Colors.transparent,
							indicatorColor: Colors.lightBlue,
							iconColorSelected: Colors.lightBlue,
							backspaceColor: Colors.lightBlue,
							skinToneDialogBgColor: Colors.white70,
						),
					),
				);
			},
		);
	}
}

// ダイアログ
class CustomDialogWidget {
	// エラーダイアログ
	void showErrorDialog(BuildContext context, String title, String message) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					backgroundColor: Colors.black87,
					shape: RoundedRectangleBorder(
						side: BorderSide(color: Colors.white70),
						borderRadius: BorderRadius.circular(10.0),
					),
					shadowColor: Colors.white70,
					title: Text(
						title,
						style: TextStyle(color: Colors.white),
					),
					content: Text(
						message,
						style: TextStyle(color: Colors.red),
					),
					actions: [
						TextButton(
							child: Text(
								"閉じる",
								style: TextStyle(color: Colors.lightBlue),
							),
							onPressed: () {
								Navigator.of(context).pop();
							}
						),
					],
				);
			},
		);
	}
}

// ログアウト確認ダイアログ
class LogoutDialogWidget {
	void showConfirmDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					backgroundColor: Colors.black87,
					shape: RoundedRectangleBorder(
						side: BorderSide(
							color: Colors.white70,
						),
						borderRadius: BorderRadius.circular(10.0),
					),
					shadowColor: Colors.white70,
					title: Text(
						"ログアウト確認",
						style: TextStyle(color: Colors.white),
					),
					content: Text(
						"ログアウトしますか？",
						style: TextStyle(color: Colors.white),
					),
					actions: [
						TextButton(
							child: Text(
								"ログアウト",
								style: TextStyle(color: Colors.lightBlue),
							),
							onPressed: () async {
								Logout logout = Logout();
								await logout.signOut();
								await Future.delayed(Duration(milliseconds: 500));

								Navigator.pushNamed(
									context,
									"/login",
								);
							}
						),
					],
				);
			},
		);
	}
}

import 'package:flutter/material.dart';

import '../model/profile.dart';
import '../model/post_merge.dart';
import '../utils/media_uploader.dart';

class UserIconWidget extends StatefulWidget {
	ProfileModel profile;
	final bool is_edit;
	String uid;

	UserIconWidget({
		required this.profile,
		required this.is_edit,
		required this.uid,
	});

	@override
	_UserIconWidgetState createState() => _UserIconWidgetState();
}

class _UserIconWidgetState extends State<UserIconWidget> {
	late ProfileModel profile;
	late String uid;

	@override
	void initState() {
		super.initState();
		profile = widget.profile;
		uid = widget.uid;
	}

	Future<void> changeImage() async {
		String? newImageUrl = await MediaUploader.pickFile(profile.uid);

		if (newImageUrl != null) {
			setState(() {
				profile.icon = newImageUrl;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return CircleAvatar(
			radius: 20.0,
			backgroundImage: NetworkImage(profile.icon) as ImageProvider,
			child:
				(widget.is_edit != false)
					?	GestureDetector(
							onTap: () {
								changeImage();
							},
							child: const Icon(
								Icons.add_a_photo,
								color: Colors.lightBlue,
							),
						)
					: GestureDetector(
							onTap: () {
								Navigator.pushNamed(
									context,
									"/profile",
									arguments: {
										"uid": uid,
										"is_self": (uid != profile.uid) ? false : true
									}
								);
							}
						),
		);
	}
}

class UserHeaderWidget extends StatefulWidget {
	ProfileModel profile;
	final bool is_edit;
	String uid;

	UserHeaderWidget({
		required this.profile,
		required this.is_edit,
		required this.uid,
	});

	@override
	_UserHeaderWidgetState createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
	late ProfileModel profile;
	late String uid;

	@override
	void initState() {
		super.initState();
		profile = widget.profile;
		uid = widget.uid;
	}

	Future<void> changeImage() async {
		String? newImageUrl = await MediaUploader.pickFile(profile.uid);

		if (newImageUrl != null) {
			setState(() {
				profile.headerfile = newImageUrl;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			height: 120,
			child: Stack(
				children: [
					if (profile.headerfile != null)
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Align(
									alignment: Alignment.topCenter,
									child: Image.network(
										profile.headerfile!,
										width: double.infinity,
										height: 100,
										fit: BoxFit.cover,
									),
								),
							],
						),
					if (profile.headerfile == null)
						Container(
							color: Colors.white,
							width: double.infinity,
							height: 100,
						),
					if (widget.is_edit)
						Positioned.fill(
							child: Align(
								alignment: Alignment.center,
								child: GestureDetector(
									onTap: () {
										changeImage();
									},
									child: const Icon(
										Icons.add_a_photo,
										color: Colors.blue,
									),
								),
							),
						),
					Positioned(
						left: 5.0,
						bottom: 0.0,
						child: CircleAvatar(
							radius: 22.0,
							backgroundColor: Colors.black87,
							child: UserIconWidget(
								profile: profile,
								is_edit: widget.is_edit,
								uid: uid
							),
						),
					),
				],
			),
		);
	}
}

// インライン配置
class UserNameWidget extends StatelessWidget {
  PostMergeModel post;
	String type; // 1: 通常, 2: 引用

  UserNameWidget({
		required this.post,
		required this.type,
	});

  @override
  Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				if (type == "1" && post.repost != null && post.is_quote == false)
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Icon(
								Icons.repeat,
								color: Colors.white70,
							),
							Text(
								post.profile.username + "が再投稿しました",
								style: TextStyle(
									color: Colors.white70,
								),
							),
						],
					),
				if (type == "1")
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Text(
								post.profile.username,
								style: TextStyle(
									color: Colors.white,
									fontWeight: FontWeight.bold,
								),
							),
							SizedBox(width: 5.0),
							Text(
								"@"+ post.profile.acount,
								style: TextStyle(
									color: Colors.white70,
								),
							),
							SizedBox(width: 5.0),
							Text(
								post.post.formattedTimestamp!,
								style: TextStyle(
									color: Colors.white70,
								),
							),
						],
					),
				if (type == "1" && post.reply_profile != null)
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							GestureDetector(
								onTap: () {
									Navigator.pushNamed(
										context,
										"/profile",
										arguments: {
											"uid": post.reply_profile!.uid,
											"is_self": false
										}
									);
								},
								child: Text(
									'返信先: @'+ post.reply_profile!.acount,
									style: TextStyle(
										color: Colors.lightBlue,
									),
								),
							),
						],
					),
				if (type == "2" && post.repost != null)
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Text(
								post.repost!.profile.username,
								style: TextStyle(
									color: Colors.white,
									fontWeight: FontWeight.bold,
								),
							),
							SizedBox(width: 5.0),
							Text(
								"@"+ post.repost!.profile.acount,
								style: TextStyle(
									color: Colors.white70,
								),
							),
							SizedBox(width: 5.0),
							Text(
								post.repost!.post!.formattedTimestamp!,
								style: TextStyle(
									color: Colors.white70,
								),
							),
						],
					),
			],
		);
	}
}

// 縦配置
class UserNameVerticalWidget extends StatelessWidget {
  PostMergeModel post;

  UserNameVerticalWidget({
		required this.post,
	});

  @override
  Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					post.profile.username,
					textAlign: TextAlign.left,
					style: TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.bold,
					),
				),
				SizedBox(height: 4.0),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						Text(
							"@"+ post.profile.acount,
							style: TextStyle(
								color: Colors.white70,
							),
						),
						SizedBox(width: 5.0),
						Text(
							post.post.formattedTimestamp!,
							style: TextStyle(
								color: Colors.white70,
							),
						),
					],
				),
			],
		);
	}
}

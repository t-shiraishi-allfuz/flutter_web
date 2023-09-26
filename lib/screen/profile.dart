import 'package:flutter/material.dart';

import 'timeline_self.dart';
import 'reply.dart';
import 'media.dart';
import 'like.dart';

import '../login.dart';
import '../model/profile.dart';
import '../model/follow.dart';
import '../model/profile_merge.dart';
import '../utils/custom_shared.dart';
import '../utils/media_uploader.dart';
import '../widget/user.dart';
import '../widget/loading.dart';
import '../widget/floating.dart';

class Profile extends StatefulWidget {
	final Map<String, dynamic> arguments;

	Profile({required this.arguments});

	@override
	State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> with SingleTickerProviderStateMixin {
	final scaffoldKey = GlobalKey<ScaffoldState>();
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

	late TabController _controller;
	late String uid;
	late bool is_self;
	late String inputName;
	late String inputIntroduction;
	late Future<ProfileMergeModel> profileFuture;

	String? oldIcon;
	String? oldHeaderfile;

	List<Widget> _tab = [
		Tab(child: Text("投稿"),),
		Tab(child: Text("返信"),),
		Tab(child: Text("メディア"),),
		Tab(child: Text("いいね"),),
	];

	List<Widget> _buildTabPages(String uid) {
		return [
			TimelineSelf(uid: uid),
			Reply(uid: uid),
			Media(uid: uid),
			Like(uid: uid),
		];
	}

	@override
	void initState() {
		super.initState();
		_controller = TabController(length: _tab.length, vsync: this);

		uid = widget.arguments["uid"];
		is_self = widget.arguments["is_self"];
		profileFuture = fetchData();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	Future<ProfileMergeModel> fetchData() async {
		return await ProfileModel.fetchProfileMergeModel(uid);
	}

	Future<void> changeProfile(ProfileModel profile) async {
		profile.username = inputName;
		profile.introduction = inputIntroduction;
		await ProfileModel.updateData(profile);

		setState(() {
			profileFuture = fetchData();
		});
	}

	// 保存せずに編集を終えた場合はアップした画像を消してリセット
	Future<void> resetImage(ProfileModel profile) async {
		if (oldIcon != profile.icon) {
			await MediaUploader.deleteImage(profile.icon);
		}

		if (oldHeaderfile != profile.headerfile) {
			await MediaUploader.deleteImage(profile.headerfile!);
		}

		setState(() {
			profile.icon = oldIcon!;
			profile.headerfile = oldHeaderfile;
		});
	}

	// Drawerを開く
	void _openEndDrawer(BuildContext context) {
		Scaffold.of(context).openEndDrawer();
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
					oldIcon = profile.profile.icon;
					oldHeaderfile = profile.profile.headerfile;

					return Scaffold(
						key: scaffoldKey,
						appBar: AppBar(
							backgroundColor: Colors.transparent,
							automaticallyImplyLeading: false,
							toolbarHeight: 50.0,
							title: Text(
								"プロフィール",
								style: TextStyle(
									color: Colors.white,
								),
							),
							leading: IconButton(
								icon: Icon(Icons.arrow_back),
								color: Colors.white,
								onPressed: () async {
									await CustomShared.deleteUri();

									Navigator.pushNamed(
										context,
										"/mypage"
									);
								},
							),
							actions: [
								IconButton(
									icon: Icon(Icons.menu),
									color: Colors.white,
									onPressed: () {
									}
								),
							],
						),
						endDrawer: SizedBox(
							width: double.infinity,
							child: Drawer(
								child: Form(
									key: _formKey,
									child: Container(
										color: Colors.black87,
										child: ListView(
											children: [
												SizedBox(
													height: 70,
													child: DrawerHeader(
														child: Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															children: [
																IconButton(
																	icon: Icon(Icons.arrow_back),
																	color: Colors.white,
																	onPressed: () async {
																		await resetImage(profile.profile);

																		Navigator.pop(context);
																	},
																),
																SizedBox(height: 5.0),
																Text(
																	"プロフィールを編集",
																	style: TextStyle(
																		color: Colors.white
																	),
																),
																SizedBox(height: 5.0),
																OutlinedButton(
																	child: Text(
																		"保存",
																		textAlign: TextAlign.center,
																		style: TextStyle(
																			color: Colors.white,
																		),
																	),
																	style: OutlinedButton.styleFrom(
																		primary: Colors.black87,
																		shape: StadiumBorder(),
																		side: BorderSide(color: Colors.white70),
																	),
																	onPressed: () {
																		_formKey.currentState?.save();
																		changeProfile(profile.profile);
																	},
																),
															],
														),
													),
												),
												Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														UserHeaderWidget(
															profile: profile.profile,
															is_edit: true,
															uid: uid
														),
														Padding(
															padding: EdgeInsets.all(10.0),
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	Text(
																		"名前",
																		style: TextStyle(
																			fontSize: 12,
																			color: Colors.white70,
																		),
																	),
																	new TextFormField(
																		initialValue: profile.profile.username,
																		textAlignVertical: TextAlignVertical.top,
																		maxLength: 16,
																		cursorColor: Colors.white70,
																		style: TextStyle(
																			fontSize: 12,
																			color: Colors.white,
																		),
																		decoration: InputDecoration(
																			counterStyle: TextStyle(
																				color: Colors.white70,
																			),
																			enabledBorder: UnderlineInputBorder(
																				borderSide: BorderSide(
																					color: Colors.transparent,
																				),
																			),
																			focusedBorder: UnderlineInputBorder(
																				borderSide: BorderSide(
																					color: Colors.lightBlue,
																				),
																			),
																		),
																		onSaved: (String? value) {
																			inputName = value!;
																		},
																	),
																	Divider(height: 0.0, color: Colors.white),
																	SizedBox(height: 5.0),
																	Text(
																		"自己紹介",
																		style: TextStyle(
																			fontSize: 12,
																			color: Colors.white70,
																		),
																	),
																	new TextFormField(
																		initialValue: profile.profile.introduction,
																		textAlignVertical: TextAlignVertical.top,
																		maxLength: 140,
																		cursorColor: Colors.white70,
																		style: TextStyle(
																			fontSize: 12,
																			color: Colors.white,
																		),
																		decoration: InputDecoration(
																			counterStyle: TextStyle(
																				color: Colors.white70,
																			),
																			enabledBorder: UnderlineInputBorder(
																				borderSide: BorderSide(
																					color: Colors.transparent,
																				),
																			),
																			focusedBorder: UnderlineInputBorder(
																				borderSide: BorderSide(
																					color: Colors.lightBlue,
																				),
																			),
																		),
																		onSaved: (String? value) {
																			inputIntroduction = value!;
																		},
																	),
																	Divider(height: 0.0, color: Colors.white),
																],
															),
														),
													],
												),
											],
										),
									),
								),
							),
						),
						body:	Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								UserHeaderWidget(
									profile: profile.profile,
									is_edit: false,
									uid: uid
								),
								Container(
									padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0,16.0),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																profile.profile.username,
																textAlign: TextAlign.left,
																style: TextStyle(
																	fontSize: 14,
																	color: Colors.white,
																	fontWeight: FontWeight.bold,
																),
															),
															SizedBox(height: 4.0),
															Text(
																'@'+ profile.profile.acount,
																textAlign: TextAlign.left,
																style: TextStyle(
																	fontSize: 12,
																	color: Colors.white70,
																),
															),
														],
													),
													OutlinedButton(
														child: Text(
															"プロフィールを編集",
															textAlign: TextAlign.center,
															style: TextStyle(
																color: Colors.white,
															),
														),
														style: OutlinedButton.styleFrom(
															primary: Colors.black87,
															shape: StadiumBorder(),
															side: BorderSide(color: Colors.white70),
														),
														onPressed: () {
															if (scaffoldKey.currentState!.isDrawerOpen) {
																scaffoldKey.currentState!.closeEndDrawer();

															} else {
																scaffoldKey.currentState!.openEndDrawer();
															}
														},
													),
												],
											),
											SizedBox(height: 16.0),
											Text(
												profile.profile.introduction ?? "プロフィールを入力して下さい。",
												textAlign: TextAlign.left,
												style: TextStyle(
													fontSize: 12,
													color: Colors.white,
												),
											),
											SizedBox(height: 16.0),
											Row(
												children: [
													Text(
														profile.follow_count,
														textAlign: TextAlign.left,
														style: TextStyle(
															fontSize: 12,
															color: Colors.white,
														),
													),
													SizedBox(width: 2.0),
													Text(
														"フォロー",
														textAlign: TextAlign.left,
														style: TextStyle(
															fontSize: 12,
															color: Colors.white70,
														),
													),
													SizedBox(width: 16.0),
													Text(
														profile.follower_count,
														textAlign: TextAlign.left,
														style: TextStyle(
															fontSize: 12,
															color: Colors.white,
														),
													),
													SizedBox(width: 2.0),
													Text(
														"フォロワー",
														textAlign: TextAlign.left,
														style: TextStyle(
															fontSize: 12,
															color: Colors.white70,
														),
													),
												],
											),
										],
									),
								),
								Divider(height: 0.0),
								Container(
									child: TabBar(
										controller: _controller,
										tabs: _tab,
										labelColor: Colors.white,
										indicatorColor: Colors.lightBlue,
										unselectedLabelColor: Colors.grey[600],
									),
								),
								Expanded(
									child: TabBarView(
										physics: NeverScrollableScrollPhysics(),
										controller: _controller,
										children: _buildTabPages(uid),
									),
								),
							],
						),
						floatingActionButton: FloatingPostWidget(uid: profile.profile.uid),
						floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
					);
				} else {
					return Container();
				}
			},
		);
	}
}

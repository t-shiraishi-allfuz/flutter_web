import 'package:flutter/material.dart';

import '../login.dart';
import '../model/profile.dart';
import '../widget/loading.dart';
import '../widget/footer.dart';
import '../widget/footer_tabview.dart';
import '../utils/custom_shared.dart';

class Mypage extends StatefulWidget {
	const Mypage({super.key});

	@override
	State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> with TickerProviderStateMixin {
	late TabController _footerController;
	late Future<ProfileModel?> profileFuture;
	late String? uid;
	int _currentFooterIndex = 0;

	@override
	void initState() {
		super.initState();
		_footerController = TabController(length: 4, vsync: this);
		profileFuture = loadProfileData();
	}

	@override
	void dispose() {
		_footerController.dispose();
		super.dispose();
	}

	// プロフィール取得
	Future<ProfileModel?> loadProfileData() async {
		try {
			uid = await CustomShared.getUID();
			if (uid == null) {
				Login();
			}

			final loadProfile = await ProfileModel.getProfileByUid(uid!);
			if (loadProfile != null) {
				await Future.delayed(Duration(milliseconds: 1000));
				return loadProfile;
			} else {
				await _createAndSaveProfile(uid!);	
			}
		} catch (e) {
			print("エラーが発生しました: $e");
			Login();
		}
	}

	// デフォルトデータ
	Future<void> _createAndSaveProfile(String uid) async {
		ProfileModel newProfile = ProfileModel(
			uid: uid,
			icon: "https://firebasestorage.googleapis.com/v0/b/flutterweb-c3f6b.appspot.com/o/img%2Fi.jpg?alt=media&token=6bbaf7b1-d69e-4e26-ab8b-9fc797eb9909",
			username: "hoge",
			acount: "hoge",
			introduction: "自己紹介です。",
		);

		try {
			await ProfileModel.addData(newProfile);

			setState(() {
				profileFuture = loadProfileData();
			});
		} catch (e) {
			print("プロフィールの作成と保存中にエラーが発生しました: $e");
			Login();
		}
	}

	void _handleItemTapped(int index) {
		setState(() {
			_currentFooterIndex = index;
			_footerController.index = _currentFooterIndex;
		});
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<ProfileModel?>(
			future: profileFuture,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return LoadingWidget();
				} else if (snapshot.hasError || snapshot.data == null) {
					return Center(child: Text("エラーが発生しました"));
				} else {
					final profile = snapshot.data!;

					return Scaffold(
						backgroundColor: Colors.transparent,
						body: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Expanded(
									child: FooterTabView(
										footerController: _footerController,
										profile: profile
									),
								),
							],
						),
						bottomNavigationBar: Footer(
							currentIndex: _currentFooterIndex,
							onItemTapped: _handleItemTapped,
						),
					);
				}
			},
		);
	}
}

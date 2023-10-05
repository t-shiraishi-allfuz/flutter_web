import 'package:flutter/material.dart';

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
	int _currentFooterIndex = 0;

	@override
	void initState() {
		super.initState();
		_footerController = TabController(length: 4, vsync: this);
		profileFuture = getProfile();
	}

	@override
	void dispose() {
		_footerController.dispose();
		super.dispose();
	}

	// プロフィール取得
	Future<ProfileModel?> getProfile() async {
		final uid = await CustomShared.getUID();
		return await ProfileModel.getProfileByUid(uid!);
	}

	// タブ切り替え
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
						body: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Expanded(
									child: FooterTabWidget(
										footerController: _footerController,
										profile: profile
									),
								),
							],
						),
						bottomNavigationBar: FooterWidget(
							currentIndex: _currentFooterIndex,
							onItemTapped: _handleItemTapped,
						),
					);
				}
			},
		);
	}
}

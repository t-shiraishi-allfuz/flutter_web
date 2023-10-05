import 'package:flutter/material.dart';

import '../model/profile.dart';
import '../views/mypage/home.dart';
import '../views/mypage/search.dart';
import '../views/mypage/notice.dart';
import '../views/mypage/dm.dart';

// フッタータブ切り替え
class FooterTabWidget extends StatefulWidget {
	final TabController footerController;
	final ProfileModel profile;

	FooterTabWidget({
		required this.footerController,
		required this.profile
	});

	@override
	_FooterTabWidgetState createState() => _FooterTabWidgetState();
}

class _FooterTabWidgetState extends State<FooterTabWidget> {
	late TabController _footerController;
	late ProfileModel profile;

	@override
	void initState() {
		super.initState();
		profile = widget.profile;
		_footerController = widget.footerController;
	}

	List<Widget> _footerBuildTabPages() {
		return [
			HomeScreen(profile: profile),
			SearchScreen(),
			NoticeScreen(uid: profile.uid),
			DmScreen(uid: profile.uid),
		];
	}

	@override
	Widget build(BuildContext context) {
		return TabBarView(
			physics: NeverScrollableScrollPhysics(),
			controller: _footerController,
			children:  _footerBuildTabPages(),
		);
	}
}
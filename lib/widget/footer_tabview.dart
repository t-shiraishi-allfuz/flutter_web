import 'package:flutter/material.dart';

import '../model/profile.dart';
import '../screen/home.dart';
import '../screen/search.dart';
import '../screen/notice.dart';
import '../screen/dm.dart';

class FooterTabView extends StatefulWidget {
	final TabController footerController;
	final ProfileModel profile;

	FooterTabView({
		required this.footerController,
		required this.profile
	});

	@override
	_FooterTabViewState createState() => _FooterTabViewState();
}

class _FooterTabViewState extends State<FooterTabView> {
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

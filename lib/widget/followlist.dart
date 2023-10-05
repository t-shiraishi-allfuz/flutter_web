import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/profile_merge.dart';
import '../utils/profile_manager.dart';
import '../utils/custom_shared.dart';
import '../widget/user.dart';
import '../widget/common.dart';

// フォロー・フォロワー一覧
class FollowlistWidget extends StatefulWidget {
	final ProfileMergeModel profile;

	FollowlistWidget({
		required this.profile,
	});

	@override
	_FollowlistWidgetState createState() => _FollowlistWidgetState();
}

class _FollowlistWidgetState extends State<FollowlistWidget> {
	late ProfileMergeModel profile;
	late String uid;

	@override
	void initState() {
		super.initState();
		profile = widget.profile;
	}

	// フォロー更新
	Future<void> changeFollow(ProfileMergeModel profile) async {
		ProfileManager manager = ProfileManager();

		if (profile.is_follow) {
			await manager.deleteFollow(profile.self_uid, profile.profile.uid);
		} else {
			await manager.executeFollow(profile.self_uid, profile.profile.uid);
		}
	}

	@override
	Widget build(BuildContext context) {
		ProfileManager profileManager = context.read<ProfileManager>();

		return ListTile(
			leading: UserIconWidget(
				profile: profile.profile,
				is_edit: false,
				uid: profile.profile.uid,
			),
			title: Text(
				profile.profile.username!,
				style: TextStyle(
					fontWeight: FontWeight.bold,
					color: Colors.white,
				),
			),
			subtitle: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Text(
								"@"+ profile.profile.acount!,
								style: TextStyle(color: Colors.white70),
							),
							if (profile.is_follower)
								SizedBox(width: 5.0),
								showFollowerWidget(),
						],	
					),
					SizedBox(height: 5.0),
					Text(
						profile.profile.introduction ?? "プロフィールを入力して下さい。",
						style: TextStyle(color: Colors.white70),
					),
				],
			),
			trailing:	Visibility(
				visible: (profile.self_uid == profile.profile.uid) ? false : true,
				child: ElevatedButton(
					style: ElevatedButton.styleFrom(
						primary: (profile.is_follow) ? Colors.black87 : Colors.white,
						shape: StadiumBorder(),
						side: BorderSide(
							color: (profile.is_follow) ? Colors.white70 : Colors.black87,
						),
					),
					child: Text(
						(profile.is_follow) ? "フォロー中" : "フォロー",
						style: TextStyle(
							color: (profile.is_follow) ? Colors.white : Colors.black,
						),
					),
					onPressed: () async {
						await changeFollow(profile);
						profileManager.fetchData();
					},
				),
			)
		);
	}
}

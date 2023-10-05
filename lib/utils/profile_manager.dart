import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/profile_merge.dart';
import '../model/profile.dart';
import '../model/follow.dart';

// プロフィール関連共通メソッド
class ProfileManager extends ChangeNotifier {
	bool is_change = false;

	void fetchData() {
		is_change = true;

		notifyListeners();
		print("変更通知1");
	}

	void resetChange() {
		is_change = false;

		notifyListeners();
		print("変更通知2");
	}

	// フォロー追加
	Future<void> executeFollow(String uid, String follow_uid) async {
		FollowModel newPost = FollowModel(
			uid: uid,
			follow_uid: follow_uid,
		);
		await FollowModel.addData(newPost);
	}

	// フォロー削除
	Future<void> deleteFollow(String uid, String follow_uid) async {
		await FollowModel.deleteData(uid, follow_uid);
	}
}

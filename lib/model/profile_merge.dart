import 'package:flutter/material.dart';

import 'profile.dart';
import 'follow.dart';

// ユーザーデータ結合用
class ProfileMergeModel {
	final ProfileModel profile;
	String follow_count;
	String follower_count;
	String self_uid;
	bool is_follow;
	bool is_follower;

	ProfileMergeModel({
		required this.profile,
		required this.follow_count,
		required this.follower_count,
		required this.self_uid,
		required this.is_follow,
		required this.is_follower,
	});

	Map<String, dynamic> toMap() {
		return {
			'profile': profile,
			'follow_count': follow_count,
			'follower_count': follower_count,
			'self_uid': self_uid,
			'is_follow': is_follow,
			'is_follower': is_follower,
		};
	}

	factory ProfileMergeModel.fromMap(Map<String, dynamic> map) {
		return ProfileMergeModel(
			profile: map['profile'],
			follow_count: map['follow_count'],
			follower_count: map['follower_count'],
			self_uid: map['self_uid'],
			is_follow: map['is_follow'],
			is_follower: map['is_follower'],
		);
	}

	@override
	String toString() {
		return 'ProfileMergeModel('
			'profile: $profile,'
			'follow_count: $follow_count,'
			'follower_count: $follower_count,'
			'self_uid: $self_uid,'
			'is_follow: $is_follow,'
			'is_follower: $is_follower,'
		')';
	}
}

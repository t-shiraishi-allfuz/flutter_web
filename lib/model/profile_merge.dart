import 'package:flutter/material.dart';

import 'profile.dart';
import 'follow.dart';

// ユーザーデータ結合用
class ProfileMergeModel {
	final ProfileModel profile;
	String follow_count;
	String follower_count;

	ProfileMergeModel({
		required this.profile,
		required this.follow_count,
		required this.follower_count,
	});

	Map<String, dynamic> toMap() {
		return {
			'profile': profile,
			'follow_count': follow_count,
			'follower_count': follower_count,
		};
	}

	factory ProfileMergeModel.fromMap(Map<String, dynamic> map) {
		return ProfileMergeModel(
			profile: map['profile'],
			follow_count: map['follow_count'],
			follower_count: map['follower_count'],
		);
	}

	@override
	String toString() {
		return 'ProfileMergeModel('
			'profile: $profile,'
			'follow_count: $follow_count,'
			'follower_count: $follower_count'
		')';
	}
}

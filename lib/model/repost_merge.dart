import 'package:flutter/material.dart';

import 'post.dart';
import 'profile.dart';

// 投稿データ結合用
class RepostMergeModel {
	final PostModel? post;
	final ProfileModel profile;

	RepostMergeModel({
		this.post,
		required this.profile,
	});

	Map<String, dynamic> toMap() {
		return {
			'post': post,
			'profile': profile,
		};
	}

	factory RepostMergeModel.fromMap(Map<String, dynamic> map) {
		return RepostMergeModel(
			post: map['post'],
			profile: map['profile'],
		);
	}

	@override
	String toString() {
		return 'RepostMergeModel('
			'post: $post,'
			'profile: $profile,'
		')';
	}
}

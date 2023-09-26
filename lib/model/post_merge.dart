import 'package:flutter/material.dart';

import 'post.dart';
import 'profile.dart';
import 'repost_merge.dart';

// 投稿データ結合用
class PostMergeModel {
	final PostModel post;
	final ProfileModel profile;
	String reply_count;
	bool is_reply;
	String repost_count;
	bool is_repost;
	bool is_quote;
	String like_count;
	bool is_like;
	ProfileModel? reply_profile;
	RepostMergeModel? repost;

	PostMergeModel({
		required this.post,
		required this.profile,
		required this.reply_count,
		required this.is_reply,
		required this.repost_count,
		required this.is_repost,
		required this.is_quote,
		required this.like_count,
		required this.is_like,
		this.reply_profile,
		this.repost,
	});

	Map<String, dynamic> toMap() {
		return {
			'post': post,
			'profile': profile,
			'reply_count': reply_count,
			'is_reply': is_reply,
			'repost_count': repost_count,
			'is_repost': is_repost,
			'is_quote': is_quote,
			'like_count': like_count,
			'is_like': is_like,
			'reply_profile': reply_profile,
			'repost': repost,
		};
	}

	factory PostMergeModel.fromMap(Map<String, dynamic> map) {
		return PostMergeModel(
			post: map['post'],
			profile: map['profile'],
			reply_count: map['reply_count'],
			is_reply: map['is_reply'],
			repost_count: map['repost_count'],
			is_repost: map['is_repost'],
			is_quote: map['is_quote'],
			like_count: map['like_count'],
			is_like: map['is_like'],
			reply_profile: map['reply_profile'],
			repost: map['repost'],
		);
	}

	@override
	String toString() {
		return 'PostMergeModel('
			'post: $post,'
			'profile: $profile,'
			'reply_count: $reply_count,'
			'is_reply: $is_reply,'
			'repost_count: $repost_count,'
			'is_repost: $is_repost,'
			'is_quote: $is_quote,'
			'like_count: $like_count,'
			'is_like: $is_like,'
			'reply_profile: $reply_profile,'
			'repost: $repost,'
		')';
	}
}

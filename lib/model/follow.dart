import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// フォロー管理
class FollowModel {
	static final CollectionReference store_follow = FirebaseFirestore.instance.collection('follow');

	final String uid;
	final String follow_uid;

	FollowModel({
		required this.uid,
		required this.follow_uid,
	});

	Map<String, dynamic> toMap() {
		return {
			'uid': uid,
			'follow_uid': follow_uid,
		};
	}

	factory FollowModel.fromMap(Map<String, dynamic> map) {
		return FollowModel(
			uid: map['uid'],
			follow_uid: map['follow_uid'],
		);
	}

	// データ追加
	static Future<void> addData(FollowModel newFollow) async {
		await store_follow.add(newFollow.toMap());
	}

	// 対象ユーザーのフォローを取得
	static Future<List<String>> getFollowList(String uid) async {
		List<String> followlist = [];

		final snapshot = await store_follow.where('uid', isEqualTo: uid).get();
		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				FollowModel follow = FollowModel.fromMap(doc.data() as Map<String, dynamic>);
				followlist.add(follow.follow_uid);
			});
		}
		return followlist;
	}

	// 対象ユーザーをフォローしているユーザーを取得
	static Future<List<String>> getFollowerList(String uid) async {
		List<String> followerlist = [];

		final snapshot = await store_follow.where('follow_uid', isEqualTo: uid).get();
		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				FollowModel follow = FollowModel.fromMap(doc.data() as Map<String, dynamic>);
				followerlist.add(follow.uid);
			});
		}
		return followerlist;
	}

	// 対象ユーザーがフォローしているユーザー数を取得
	static Future<String> countFollow(String uid) async {
		List<String> followList = await FollowModel.getFollowList(uid);
		return followList.length.toString();
	}

	// 対象ユーザーをフォローしているユーザー数を取得
	static Future<String> countFollower(String uid) async {
		List<String> followerList = await FollowModel.getFollowerList(uid);
		return followerList.length.toString();
	}
}

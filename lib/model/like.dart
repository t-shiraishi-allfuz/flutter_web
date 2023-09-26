import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// いいね管理
class LikeModel {
	static final CollectionReference store_like = FirebaseFirestore.instance.collection('like');

	final String uid;
	final String post_id;

	LikeModel({
		required this.uid,
		required this.post_id,
	});

	Map<String, dynamic> toMap() {
		return {
			'uid': uid,
			'post_id': post_id,
		};
	}

	factory LikeModel.fromMap(Map<String, dynamic> map) {
		return LikeModel(
			uid: map['uid'],
			post_id: map['post_id'],
		);
	}

	@override
	String toString() {
		return 'LikeModel('
			'uid: $uid,'
			'post_id: $post_id,'
		')';
	}

	// データ追加
	static Future<void> addData(LikeModel newLike) async {
		await store_like.add(newLike.toMap());
	}

	// データ削除
	static Future<void> deleteLikeById(String uid, String post_id) async {
			final snapshot = await store_like
				.where('uid', isEqualTo: uid)
				.where('post_id', isEqualTo: post_id)
				.get();

			snapshot.docs.forEach((doc) {
				doc.reference.delete();
			});
	}

	// 対象ユーザーのいいねした投稿IDを取得
	static Future<List<String>> getLikePostIds(String uid)  async {
		List<String> likelist = [];

		final snapshot = await store_like.where('uid', isEqualTo: uid).get();
		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				LikeModel like = LikeModel.fromMap(doc.data() as Map<String, dynamic>);
				likelist.add(like.post_id);
			});
		}
		return likelist;
	}

	// 対象の投稿をいいねしてるかどうか
	static Future<bool> isLike(String uid, String post_id) async {
		bool is_like = false;

		final snapshot = await store_like
			.where('uid', isEqualTo: uid)
			.where('post_id', isEqualTo: post_id)
			.get();

		if (snapshot.docs.isNotEmpty) {
			is_like = true;
		}
		return is_like;
	}

	// 対象の投稿をいいねしている数を取得
	static Future<String> countLike(String post_id) async {
		List<String> likelist = [];

		final snapshot = await store_like.where('post_id', isEqualTo: post_id).get();
		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				LikeModel like = LikeModel.fromMap(doc.data() as Map<String, dynamic>);
				likelist.add(like.uid);
			});
		}
		return likelist.length.toString();
	}
}

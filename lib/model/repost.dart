import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 再投稿管理
class RepostModel {
	static final CollectionReference store_repost = FirebaseFirestore.instance.collection('repost');

	final String uid;
	final String post_id;
	final bool is_quote;

	RepostModel({
		required this.uid,
		required this.post_id,
		required this.is_quote,
	});

	Map<String, dynamic> toMap() {
		return {
			'uid': uid,
			'post_id': post_id,
			'is_quote': is_quote
		};
	}

	factory RepostModel.fromMap(Map<String, dynamic> map) {
		return RepostModel(
			uid: map['uid'],
			post_id: map['post_id'],
			is_quote: map['is_quote'],
		);
	}

	@override
	String toString() {
		return 'RepostModel('
			'uid: $uid,'
			'post_id: $post_id,'
			'is_quote: $is_quote,'
		')';
	}

	// データ追加
	static Future<void> addData(RepostModel newRepost) async {
		await store_repost.add(newRepost.toMap());
	}

	// データ削除
	static Future<void> deleteRepostById(String uid, String post_id) async {
		final snapshot = await store_repost
			.where('uid', isEqualTo: uid)
			.where('post_id', isEqualTo: post_id)
			.get();

		snapshot.docs.forEach((doc) {
			doc.reference.delete();
		});
	}

	// データ取得
	static Future<RepostModel?> getRepostById(String uid, String? post_id) async {
		if (post_id == null) {
			return null;
		}

		final snapshot = await store_repost
			.where('uid', isEqualTo: uid)
			.where('post_id', isEqualTo: post_id)
			.get();

		if (snapshot.docs.isNotEmpty) {
			return RepostModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
		}
	}

	// 対象の投稿を再投稿してるかどうか
	static Future<bool> isRepost(String uid, String post_id)  async {
		bool is_repost = false;
		RepostModel? repost = await getRepostById(uid, post_id);

		if (repost != null) {
			is_repost = true;
		}
		return is_repost;
	}

	// 対象の投稿を再投稿している数を取得
	static Future<String> countRepost(String post_id) async {
		List<RepostModel> repostList = [];

		final snapshot = await store_repost.where('post_id', isEqualTo: post_id).get();
		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				RepostModel repost = RepostModel.fromMap(doc.data() as Map<String, dynamic>);
				repostList.add(repost);
			});
		}
		return repostList.length.toString();
	}
}

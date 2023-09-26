import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'profile.dart';
import 'repost.dart';
import 'like.dart';
import 'post_merge.dart';
import 'repost_merge.dart';

// 投稿管理
class PostModel {
	static final CollectionReference store_post = FirebaseFirestore.instance.collection('post');

	String id;
	final String uid;
	final String? reply_post_id;  // 返信したID
	final String? repost_post_id; // 再投稿したID
	final String content;
	final String? mediafile;
	final String timestamp;
	String? formattedTimestamp;
	final bool is_media;

	PostModel({
		required this.id,
		required this.uid,
		this.reply_post_id,
		this.repost_post_id,
		required this.content,
		this.mediafile,
		required this.timestamp,
		this.formattedTimestamp,
		required this.is_media,
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'uid': uid,
			'reply_post_id': reply_post_id,
			'repost_post_id': repost_post_id,
			'content': content,
			'mediafile': mediafile,
			'timestamp': timestamp,
			'formattedTimestamp': formattedTimestamp,
			'is_media': is_media,
		};
	}

	factory PostModel.fromMap(Map<String, dynamic> map) {
		return PostModel(
			id: map['id'],
			uid: map['uid'],
			reply_post_id: map['reply_post_id'],
			repost_post_id: map['repost_post_id'],
			content: map['content'],
			mediafile: map['mediafile'],
			timestamp: map['timestamp'],
			formattedTimestamp: map['formattedTimestamp'],
			is_media: map['is_media'],
		);
	}

	@override
	String toString() {
		return 'PostModel('
			'id: $id,'
			'uid: $uid,'
			'reply_post_id: $reply_post_id,'
			'repost_post_id: $repost_post_id,'
			'content: $content,'
			'mediafile: $mediafile,'
			'timestamp: $timestamp,'
			'formattedTimestamp: $formattedTimestamp,'
			'is_media: $is_media'
		')';
	}

	// データ追加
	static Future<void> addData(PostModel newPost) async {
		final DocumentReference documentReference = await store_post.add(newPost.toMap());
		newPost.id = documentReference.id;
		await documentReference.update(newPost.toMap());
	}

	// データ削除
	static Future<void> deletePostById(String uid, String post_id) async {
		await store_post.doc(post_id).delete();
	}

	// 再投稿データ削除
	static Future<void> deleteRepostById(String uid, String post_id) async {
		final snapshot = await store_post
			.where('uid', isEqualTo: uid)
			.where('repost_post_id', isEqualTo: post_id)
			.get();

		snapshot.docs.forEach((doc) {
			doc.reference.delete();
		});
	}

	// 投稿データを作成
	static Future<PostMergeModel> fetchPostMergeModel(String uid, DocumentSnapshot doc) async {
		// 投稿日時を加工
		PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>);
		post.formattedTimestamp = formatDatatime(post);

		// 投稿者のプロフィール
		final profile = await ProfileModel.getProfileByUid(post.uid);
		// 返信数
		final reply_count = await countReply(post.id);
		// 返信があるかどうか
		final is_reply = await isReply(post.id);
		// 再投稿数
		final repost_count = await RepostModel.countRepost(post.id);
		// 自分が再投稿しているかどうか
		final is_repost = await RepostModel.isRepost(uid, post.id);
		// いいね数
		final like_count = await LikeModel.countLike(post.id);
		// 自分がいいねしているかどうか
		final is_like = await LikeModel.isLike(uid, post.id);

		// 返信関連
		final reply_profile = await getReplyData(uid, post.reply_post_id);

		// 再投稿関連
		final repost = await RepostModel.getRepostById(post.uid, post.repost_post_id);
		final repost_data = await getRepostData(repost);

		return PostMergeModel(
			post: post,
			profile: profile!,
			reply_count: reply_count,
			is_reply: is_reply,
			repost_count: repost_count,
			is_repost: is_repost,
			is_quote: repost != null ? repost!.is_quote : false,
			like_count: like_count,
			is_like: is_like,
			reply_profile: reply_profile,
			repost: repost_data,
		);
	}

	// 返信投稿データを作成
	static Future<ProfileModel?> getReplyData(String uid, String? post_id) async {
		if (post_id == null) {
			return null;
		}

		// 元データ取得
		final replySnapshot = await store_post.where('id', isEqualTo: post_id).get();
		if (replySnapshot.docs.isNotEmpty) {
			final reply = PostModel.fromMap(replySnapshot.docs.first.data() as Map<String, dynamic>);
			// 返信が自分の場合は取得しない
			if (uid == reply.uid) {
				return null;
			}
			final profile = await ProfileModel.getProfileByUid(reply.uid);
			return profile;
		}
		return null;
	}

	// 引用投稿データを作成
	static Future<RepostMergeModel?> getRepostData(RepostModel? repost) async {
		if (repost == null) {
			return null;
		}

		// プロフィールは必ず取得
		final profile = await ProfileModel.getProfileByUid(repost.uid);

		// 元データ取得
		final repostSnapshot = await store_post.where('id', isEqualTo: repost.post_id).get();
		if (repostSnapshot.docs.isNotEmpty) {
			final post = PostModel.fromMap(repostSnapshot.docs.first.data() as Map<String, dynamic>);
			post.formattedTimestamp = formatDatatime(post);

			return RepostMergeModel(
				post: post,
				profile: profile!
			);
		}
		return null;
	}

	// 投稿を全て取得
	// TODO おすすめの定義
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getAll(String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post.get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 投稿に対する返信を全て取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getReplyAll(String uid, String post_id) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post.where('reply_post_id', isEqualTo: post_id).get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象の投稿を全て取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getPostByIds(List<String> post_ids, String uid) async {
		List<PostMergeModel> posts = [];

		if (post_ids.isEmpty) {
			return posts;
		}

		final snapshot = await store_post.where(FieldPath.documentId, whereIn: post_ids).get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象の投稿を取得
	static Future<List<PostMergeModel>> getPostById(String post_id, String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot =await store_post.where('id', isEqualTo: post_id).get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象のユーザーの投稿を取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getPostByUid(String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post.where('uid', isEqualTo: uid).get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象のユーザーの投稿を取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getPostByUids(List<String> uids, String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post.where('uid', arrayContains: uids).get();
		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象のユーザーが返信した投稿を取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getPostByReply(String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post
			.where('uid', isEqualTo: uid)
			.where('reply_post_id', isNull: false)
			.get();

		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象ユーザーのメディア投稿を取得
	// 投稿降順にソート
	static Future<List<PostMergeModel>> getPostByMedia(String uid) async {
		List<PostMergeModel> posts = [];

		final snapshot = await store_post
			.where('uid', isEqualTo: uid)
			.where('is_media', isEqualTo: true)
			.get();

		if (snapshot.docs.isNotEmpty) {
			final List<Future<PostMergeModel>> futures = [];
			final set = <dynamic>{};

			for (final doc in snapshot.docs) {
				set.add(doc);
			}

			for (final doc in set) {
				futures.add(fetchPostMergeModel(uid, doc));
			}

			posts = await Future.wait(futures);
			posts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));
		}
		return posts;
	}

	// 対象の投稿に返信した投稿を取得
	static Future<QuerySnapshot> getReplyById(String post_id) async {
		return await store_post.where('reply_post_id', isEqualTo: post_id).get();
	}

	// 対象の投稿に返信があるかどうか
	static Future<bool> isReply(String post_id) async {
		bool is_reply = false;

		final snapshot = await store_post
			.where('id', isEqualTo: post_id)
			.where('reply_post_id', isNull: false)
			.get();

		if (snapshot.docs.isNotEmpty) {
			is_reply = true;
		}
		return is_reply;
	}

	// 対象の投稿の返信数取得
	static Future<String> countReply(String post_id) async {
		List<PostModel> postList = [];

		final snapshot = await store_post
			.where('reply_post_id', isEqualTo: post_id)
			.get();

		if (snapshot.docs.isNotEmpty) {
			snapshot.docs.forEach((doc) {
				PostModel repost = PostModel.fromMap(doc.data() as Map<String, dynamic>);
				postList.add(repost);
			});
		}
		return postList.length.toString();
	}

	// 再投稿を取得
	static Future<QuerySnapshot> getRepostById(String post_id) async {
		return await store_post.where('repost_post_id', isEqualTo: post_id).get();
	}

	// timestampを整形
	static String formatDatatime(PostModel post) {
		timeago.setLocaleMessages('ja', timeago.JaMessages());

		final now = DateTime.now();
		final difference = now.difference(parseTimestamp(post.timestamp));

		return timeago.format(now.subtract(difference), locale: 'ja');
	}

	static DateTime parseTimestamp(String timestamp) {
		final parts = timestamp.split("T");
		final dateParts = parts[0].split("-");
		final timeParts = parts[1].split(":");
		final year = int.parse(dateParts[0]);
		final month = int.parse(dateParts[1]);
		final day = int.parse(dateParts[2]);
		final hour = int.parse(timeParts[0]);
		final minute = int.parse(timeParts[1]);
		final second = int.parse(timeParts[2]);

		return DateTime(year, month, day, hour, minute, second);
	}
}

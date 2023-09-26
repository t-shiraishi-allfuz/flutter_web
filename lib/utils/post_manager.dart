import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/post_merge.dart';
import '../model/post.dart';
import '../model/repost.dart';
import '../model/like.dart';
import '../utils/media_uploader.dart';

// 投稿関連共通メソッド
class PostManager extends ChangeNotifier {
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

	// 投稿追加
	Future<void> executePost(String uid, String? text, String? mediafile, String? reply_post_id, String? repost_post_id) async {
		bool is_media = false;
		if (mediafile != null) {
			is_media = true;
		}

		DateTime now = DateTime.now();
		String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);

		PostModel newPost = PostModel(
			id: "",
			uid: uid,
			reply_post_id: reply_post_id ?? null,
			repost_post_id: repost_post_id ?? null,
			content: text ?? "",
			mediafile: mediafile ?? null,
			timestamp: formattedDate,
			is_media: is_media,		
		);
		await PostModel.addData(newPost);
	}

	// 再投稿データ追加
	Future<void> executeRepost(String uid, PostModel post) async {
		PostModel newPost = PostModel(
			id: "",
			uid: uid,
			reply_post_id: post.reply_post_id,
			repost_post_id: post.id,
			content: post.content,
			mediafile: post.mediafile,
			timestamp: post.timestamp,
			is_media: post.is_media,
		);
		await PostModel.addData(newPost);
	}

	// 投稿削除
	Future<void> deletePost(String uid, PostMergeModel post) async {
		// 画像付きの場合は画像も消す
		if (post.post.is_media != false) {
			await MediaUploader.deleteImage(post.post.mediafile!);
		}
		// 自分が再投稿してる場合はそれも消す
		if (post.post.repost_post_id != null) {
			await RepostModel.deleteRepostById(uid, post.post.repost_post_id!);
			await PostModel.deleteRepostById(uid, post.post.id);
		}
		// いいねしてる場合はそれも消す
		if (post.is_like != false) {
			await LikeModel.deleteLikeById(uid, post.post.id);
		}
		// 投稿削除
		await PostModel.deletePostById(uid, post.post.id);
	}

	// 再投稿
	Future<void> addRepost(String uid, String? text, String? mediafile, PostMergeModel post, bool is_quote) async {
		// 再投稿データを追加
		if (post.is_repost == false) {
			RepostModel newRepost = RepostModel(
				uid: uid,
				post_id: post.post.id,
				is_quote: is_quote
			);
			await RepostModel.addData(newRepost);
			// さらに該当の投稿データを追加する
			if (is_quote == false) {
				await executeRepost(uid, post.post);
			}
		} else if (is_quote == false) {
			// 既に再投稿していて引用ではない場合は取り消し
			await RepostModel.deleteRepostById(uid, post.post.id);
		}
	}

	// いいね
	Future<void> addLike(String uid, PostMergeModel post) async {
		if (post.is_like == false) {
			LikeModel newLike = LikeModel(
				uid: uid,
				post_id: post.post.id
			);
			await LikeModel.addData(newLike);
		} else {
			// 既にいいねしてる場合は取り消し
			await LikeModel.deleteLikeById(uid, post.post.id);
		}
	}
}

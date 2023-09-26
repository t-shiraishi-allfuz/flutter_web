import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'follow.dart';
import 'profile_merge.dart';

// プロフィール管理
class ProfileModel {
	static final CollectionReference store_profile = FirebaseFirestore.instance.collection('profile');

	final String uid;
	String icon;
	String username;
	String acount;
	String? introduction;
	String? headerfile;

	ProfileModel({
		required this.uid,
		required this.icon,
		required this.username,
		required this.acount,
		this.introduction,
		this.headerfile,
	});

	ProfileModel copyWith({String? icon, String? username, String? acount, String? introduction, String? headerfile}) => ProfileModel(
		uid: this.uid,
		icon: icon ?? this.icon,
		username: username ?? this.username,
		acount: acount ?? this.acount,
		introduction: introduction ?? this.introduction,
		headerfile: headerfile ?? this.headerfile
	);

	Map<String, dynamic> toMap() {
		return {
			'uid': uid,
			'icon': icon,
			'username': username,
			'acount': acount,
			'introduction': introduction,
			'headerfile': headerfile,
		};
	}

	factory ProfileModel.fromMap(Map<String, dynamic> map) {
		return ProfileModel(
			uid: map['uid'],
			icon: map['icon'],
			username: map['username'],
			acount: map['acount'],
			introduction: map['introduction'],
			headerfile: map['headerfile'],
		);
	}

	@override
	String toString() {
		return 'ProfileModel('
			'uid: $uid,'
			'icon: $icon,'
			'username: $username,'
			'acount: $acount,'
			'introduction: $introduction,'
			'headerfile: $headerfile'
		')';
	}

	// データ追加
	static Future<void> addData(ProfileModel newProfile) async {
		final DocumentReference newDocRef = store_profile.doc(newProfile.uid);
		await newDocRef.set(newProfile.toMap());
	}

	// データ更新
	static Future<void> updateData(ProfileModel updateProfile) async {
		final DocumentReference userDocRef = store_profile.doc(updateProfile.uid);
		await userDocRef.update(updateProfile.toMap());
	}

	// ユーザーデータを作成
	static Future<ProfileMergeModel> fetchProfileMergeModel(String uid) async {
		// プロフィール取得
		final ProfileModel? profile = await getProfileByUid(uid);

		// フォロー数取得
		final String follow_count = await FollowModel.countFollow(uid);

		// フォロワー数取得
		final String follower_count = await FollowModel.countFollower(uid);

		return ProfileMergeModel(
			profile: profile!,
			follow_count: follow_count,
			follower_count: follower_count,
		);
	}

	// データ取得
	static Future<ProfileModel?> getProfileByUid(String uid) async {
		final snapshot = await store_profile.where('uid', isEqualTo: uid).get();
		if (snapshot.docs.isNotEmpty) {
			return ProfileModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
		} else {
			return null;
		}
	}
}

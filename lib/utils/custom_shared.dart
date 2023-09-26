import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String uidKey = 'user_uid';
const String uriKey = 'current_uri';

class CustomShared {
	// UIDを保存
	static Future<void> saveUID(String uid) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(uidKey, uid);
	}

	// UIDを取得
	static Future<String?> getUID() async {
		final prefs = await SharedPreferences.getInstance();

		try {
			return prefs.getString(uidKey);
		} catch (e) {
			throw e;
		}
	}

	// UIDを削除
	static Future<void> deleteUID() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.remove(uidKey);
	}

	// リクエストURLを保存
	static Future<void> saveUri(String routeName, Map<String, dynamic> params) async {
		final prefs = await SharedPreferences.getInstance();

		Map<String, dynamic> newSetting = {
			"routeName": routeName,
			"params": params
		};
		await prefs.setString(uriKey, jsonEncode(newSetting));
	}

	// リクエストURLを取得
	static Future<Map<String, dynamic>?> getUri() async {
		final prefs = await SharedPreferences.getInstance();

		try {
			final json = prefs.getString(uriKey);
			if (json == null) {
				return null;
			}
			return jsonDecode(json!);
		} catch (e) {
			await deleteUri();

			throw e;
		}
	}
 
	// リクエストURLを削除
	static Future<void> deleteUri() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.remove(uriKey);
	}
}

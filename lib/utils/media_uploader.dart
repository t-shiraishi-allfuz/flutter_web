import 'dart:html';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MediaUploader {
	static final FileUploadInputElement input = FileUploadInputElement();

	static Future<String?> pickFile(String uid) async {
		final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

		input.click();

		final fileEvent = await input.onChange.first;
		if (fileEvent != null) {
			final file = input.files!.first;
			final firebase_storage.Reference ref = storage.ref("img/${uid}/${file.name}");
			final firebase_storage.UploadTask uploadTask = ref.putBlob(file);

			final snapshot = await uploadTask;
			final downloadUrl = await snapshot.ref.getDownloadURL();

			return downloadUrl;
		}
		return null;
	}

	static Future<void> deleteImage(String Url) async {
		final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
		final firebase_storage.Reference ref = storage.refFromURL(Url);

		try {
			await ref.delete();
		} catch (e) {
			throw e;
		}
	}

	static Future<Map<String, int>> getImageSize(String imageUrl) async {
		final ImageElement image = ImageElement(src: imageUrl);
		await image.onLoad.first;

		final int width = image.width ?? 0;
		final int height = image.height ?? 0;

		return {
			"width": width,
			"height": height
		};
	}
}

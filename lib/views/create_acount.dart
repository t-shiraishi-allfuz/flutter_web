import 'dart:core';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../model/profile.dart';
import '../utils/custom_shared.dart';
import '../utils/media_uploader.dart';
import '../widget/dialog.dart';

// 新規アカウント登録
class CreateNewAcount extends StatefulWidget {
	CreateNewAcount({super.key});
	
	@override
	State<CreateNewAcount> createState() => _CreateNewAcountState();
}

class _CreateNewAcountState extends State<CreateNewAcount> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	TextEditingController _textMailController = TextEditingController();
	TextEditingController _textPassController = TextEditingController();

	late String inputMail;
	late String inputPass;
	bool isDisplay = true;

	FirebaseAuth auth = FirebaseAuth.instance;
	User? user;

	@override
	void dispose() {
		_textMailController.dispose();
		_textPassController.dispose();
		super.dispose();
	}

	// メアド登録
	Future<void> handleSignIn(BuildContext context) async {
		try {
			final UserCredential authResult = await auth.createUserWithEmailAndPassword(
				email: inputMail,
				password: inputPass,
			);
			user = authResult.user;

			if (user != null) {
				await CustomShared.saveUID(user!.uid);
				await createAndSaveProfile(user!.uid, context);
			}
		} on FirebaseAuthException catch (e) {
			print("登録エラー：${e.code}");
			String title = "登録エラー";
			String message = "予期せぬエラーが発生しました";

			if (e.code == "email-already-in-use") {
				String message = "登録済みのメールアドレスです";
			}
			CustomDialogWidget dialog = CustomDialogWidget();
			dialog.showErrorDialog(context, title, message);
		}
	}

	// Google認証
	Future<void> handleSignInGoogle(BuildContext context) async {
		GoogleAuthProvider authProvider = GoogleAuthProvider();

		try {
			final UserCredential authResult = await auth.signInWithPopup(authProvider);
			user = authResult.user;

			if (user != null) {
				await CustomShared.saveUID(user!.uid);
				await createAndSaveProfile(user!.uid, context);
			}
		} on FirebaseAuthException catch (e) {
			print("登録エラー：${e.code}");
			String title = "登録エラー";
			String message = "予期せぬエラーが発生しました";

			if (e.code == "email-already-in-use") {
				String message = "登録済みのメールアドレスです";
			}
			CustomDialogWidget dialog = CustomDialogWidget();
			dialog.showErrorDialog(context, title, message);
		}
	}

	// デフォルトデータ
	Future<void> createAndSaveProfile(String uid, BuildContext context) async {
		ProfileModel newProfile = ProfileModel(
			uid: uid,
			icon: "https://firebasestorage.googleapis.com/v0/b/flutterweb-c3f6b.appspot.com/o/img%2Fi.jpg?alt=media&token=6bbaf7b1-d69e-4e26-ab8b-9fc797eb9909",
			username: null,
			acount: null,
			introduction: "自己紹介です。",
		);

		try {
			await ProfileModel.addData(newProfile);

			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => CreateProfile1(profile: newProfile))
			);
		} catch (e) {
			print(e);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.black87,
				title: const Text(
					"新規アカウント登録",
					style: TextStyle(
						color: Colors.white
					),
				),
			),
			body: Container(
				padding: EdgeInsets.all(16.0),
				alignment: Alignment.center,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Form(
							key: _formKey,
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										"メールアドレス",
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 5.0),
									new TextFormField(
										controller: _textMailController,
										autofocus: true,
										maxLines: 1,
										cursorColor: Colors.lightBlue,
										decoration: InputDecoration(
											hintText: "登録するメールアドレスを入力して下さい",
											hintStyle: TextStyle(color: Colors.grey),
											enabledBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.white70),
											),
											focusedBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.lightBlue),
											),
										),
										keyboardType: TextInputType.emailAddress,
										validator: (value) {
											if (value == "" || value == null || value.isEmpty) {
												return "メールアドレスが入力されていません";
											} else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
												return "メールアドレスが正しくありません";
											}
											return null;
										},
										onSaved: (value) {
											inputMail = value!;
										},
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 8.0),
									Text(
										"パスワード",
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 5.0),
									new TextFormField(
										controller: _textPassController,
										maxLines: 1,
										cursorColor: Colors.lightBlue,
										obscureText: isDisplay,
										decoration: InputDecoration(
											hintText: "英数字8文字以上のパスワードを入力して下さい",
											hintStyle: TextStyle(color: Colors.grey),
											enabledBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.white70),
											),
											focusedBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.lightBlue),
											),
											suffixIcon: IconButton(
												icon: Icon(isDisplay ? Icons.visibility_off : Icons.visibility),
												onPressed: () {
													setState(() {
														isDisplay = !isDisplay;
													});
												}
											),
										),
										validator: (value) {
											if (value == "" || value == null || value.isEmpty) {
												return "パスワードが入力されていません";
											} else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
												return "パスワードは8文字以上の英数字で入力して下さい";
											}
											return null;
										},
										onSaved: (value) {
											inputPass = value!;
										},
										style: TextStyle(color: Colors.white),
									),
								],
							),
						),
						SizedBox(height: 10.0),
						ElevatedButton(
							child: Text(
								"登録",
								style: TextStyle(color: Colors.black),
							),
							onPressed: () async {
								// 入力チェック
								if (_formKey.currentState!.validate()) {
									_formKey.currentState?.save();
									await handleSignIn(context);
								}
							},
						),
						SizedBox(height: 10.0),
						Padding(
							padding: EdgeInsets.all(16.0),
							child: SignInButton(
								text: "Googleで登録",
								Buttons.google,
								onPressed: () async {
									await handleSignInGoogle(context);
								}
							),
						),
					],
				),
			),
		);
	}
}

// プロフィール登録1
class CreateProfile1 extends StatefulWidget {
	ProfileModel profile;

	CreateProfile1({
		required this.profile
	});

	@override
	State<CreateProfile1> createState() => _CreateProfile1State();
}

class _CreateProfile1State extends State<CreateProfile1> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	TextEditingController _textController = TextEditingController();

	late ProfileModel profile;
	late String inputName;

	@override
	initState() {
		super.initState();

		profile = widget.profile;
	}

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	// プロフィール更新
	Future<void> changeProfile(ProfileModel profile, BuildContext context) async {
		profile.username = inputName;
		await ProfileModel.updateData(profile);

		Navigator.push(
			context,
			MaterialPageRoute(builder: (context) => CreateProfile2(profile: profile))
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				title: const Text(
					"プロフィール登録",
					style: TextStyle(color: Colors.white),
				),
			),
			body: Container(
				padding: EdgeInsets.all(16.0),
				alignment: Alignment.center,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Form(
							key: _formKey,
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										"ユーザー名",
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 5.0),
									new TextFormField(
										controller: _textController,
										autofocus: true,
										maxLines: 1,
										maxLength: 20,
										cursorColor: Colors.lightBlue,
										decoration: InputDecoration(
											hintText: "ユーザー名を入力して下さい",
											hintStyle: TextStyle(color: Colors.grey),
											counterStyle: TextStyle(color: Colors.white70),
											enabledBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.white70),
											),
											focusedBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.lightBlue),
											),
										),
										validator: (value) {
											if (value == "" || value == null || value.isEmpty) {
												return "ユーザー名が入力されていません";
											}
										},
										onSaved: (value) {
											inputName = value!;
										},
										style: TextStyle(color: Colors.white),
									),
								],
							),
						),
						SizedBox(height: 8.0),
						ElevatedButton(
							child: Text(
								"次へ",
								style: TextStyle(color: Colors.black),
							),
							onPressed: () async {
								// 入力チェック
								if (_formKey.currentState!.validate()) {
									_formKey.currentState?.save();
									await changeProfile(profile, context);
								}
							},
						),
					],
				),
			),
		);
	}
}

// プロフィール登録2
class CreateProfile2 extends StatefulWidget {
	ProfileModel profile;

	CreateProfile2({
		required this.profile
	});

	@override
	State<CreateProfile2> createState() => _CreateProfile2State();
}

class _CreateProfile2State extends State<CreateProfile2> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	TextEditingController _textController = TextEditingController();

	late ProfileModel profile;
	late String inputName;

	@override
	initState() {
		super.initState();

		profile = widget.profile;
	}

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	// プロフィール更新
	Future<void> changeProfile(ProfileModel profile, BuildContext context) async {
		profile.acount = inputName;
		await ProfileModel.updateData(profile);

		Navigator.push(
			context,
			MaterialPageRoute(builder: (context) => CreateProfile3(profile: profile))
		);
	}

	// アカウント重複チェック
	Future<bool> checkDuplicateAcount() async {
		return await ProfileModel.checkDuplicateAcount(inputName);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				title: const Text(
					"プロフィール登録",
					style: TextStyle(color: Colors.white),
				),
			),
			body: Container(
				padding: EdgeInsets.all(16.0),
				alignment: Alignment.center,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Form(
							key: _formKey,
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										"アカウント名",
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 5.0),
									new TextFormField(
										controller: _textController,
										autofocus: true,
										maxLines: 1,
										maxLength: 20,
										cursorColor: Colors.lightBlue,
										decoration: InputDecoration(
											hintText: "アカウント名を入力して下さい",
											hintStyle: TextStyle(color: Colors.grey),
											counterStyle: TextStyle(color: Colors.white70),
											enabledBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.white70),
											),
											focusedBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.lightBlue),
											),
										),
										validator: (value) {
											if (value == "" || value == null || value.isEmpty) {
												return "アカウント名が入力されていません";
											} else if (!RegExp(r'^[A-Za-z\d]+$').hasMatch(value)) {
												return "アカウントは英数字で入力して下さい";
											}
											return null;
										},
										onSaved: (value) {
											inputName = value!;
										},
										style: TextStyle(color: Colors.white),
									),
								],
							),
						),
						SizedBox(height: 8.0),
						ElevatedButton(
							child: Text(
								"次へ",
								style: TextStyle(color: Colors.black),
							),
							onPressed: () async {
								// 入力チェック
								if (_formKey.currentState!.validate()) {
									_formKey.currentState?.save();

									final isDuplicate = await checkDuplicateAcount();
									if (isDuplicate == false) {
										await changeProfile(profile, context);
									} else {
										CustomDialogWidget dialog = CustomDialogWidget();
										dialog.showErrorDialog(context, "登録エラー", "既に使用されているアカウント名です");
									}
								}
							},
						),
					],
				),
			),
		);
	}
}

// プロフィール登録3
class CreateProfile3 extends StatefulWidget {
	ProfileModel profile;

	CreateProfile3({
		required this.profile
	});

	@override
	State<CreateProfile3> createState() => _CreateProfile3State();
}

class _CreateProfile3State extends State<CreateProfile3> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	TextEditingController _textController = TextEditingController();

	late ProfileModel profile;

	@override
	initState() {
		super.initState();

		profile = widget.profile;
	}

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	// アイコン選択
	Future<void> changeImage() async {
		String? newImageUrl = await MediaUploader.pickFile(profile.uid);

		if (newImageUrl != null) {
			setState(() {
				profile.icon = newImageUrl;
			});
		}
	}

	// プロフィール更新
	Future<void> changeProfile(ProfileModel profile, BuildContext context) async {
		await ProfileModel.updateData(profile);

		Navigator.pushNamed(
			context,
			"/mypage"
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				title: const Text(
					"プロフィール登録",
					style: TextStyle(color: Colors.white),
				),
			),
			body: Container(
				padding: EdgeInsets.all(16.0),
				alignment: Alignment.center,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text(
							"プロフィールアイコンを設定しましょう",
							style: TextStyle(color: Colors.white),
						),
						SizedBox(height: 10.0),
						Container(
							width: 100.0,
							height: 100.0,
							child: CircleAvatar(
								radius: 20.0,
								backgroundImage: NetworkImage(profile.icon) as ImageProvider,
								child: GestureDetector(
									onTap: () {
										changeImage();
									},
									child: const Icon(
										Icons.add_a_photo,
										color: Colors.lightBlue,
									),
								),
							),
						),
						SizedBox(height: 10.0),
						ElevatedButton(
							child: Text(
								"次へ",
								style: TextStyle(color: Colors.black),
							),
							onPressed: () async {
								await changeProfile(profile, context);
							},
						),
					],
				),
			),
		);
	}
}

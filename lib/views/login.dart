import 'dart:core';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../model/profile.dart';
import '../utils/custom_shared.dart';
import '../views/create_acount.dart';
import '../widget/dialog.dart';

// ログイン
class Login extends StatefulWidget {
	Login({super.key});
	
	@override
	State<Login> createState() => _createLoginState();
}

class _createLoginState extends State<Login> {
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

	// メアド認証
	Future<void> handleSignIn(BuildContext context) async {
		try {
			final UserCredential authResult = await auth.signInWithEmailAndPassword(
				email: inputMail,
				password: inputPass,
			);
			user = authResult.user;

			if (user != null) {
				await CustomShared.saveUID(user!.uid);
				final profile = await getProfile(user!.uid);

				checkProgress(profile, context);
			} else {
				await auth.signOut();
			}
		} on FirebaseAuthException catch (e) {
			print(e);
			String title = "認証エラー";
			String message = "アカウントが存在しません";

			CustomDialogWidget dialog = CustomDialogWidget();
			dialog.showErrorDialog(context, title, message);
		}
		return null;
	}

	// Google認証
	Future<void> handleSignInGoogle(BuildContext context) async {
		GoogleAuthProvider authProvider = GoogleAuthProvider();

		try {
			await auth.signOut();
			final UserCredential authResult = await auth.signInWithPopup(authProvider);
			user = authResult.user;

			if (user != null) {
				await CustomShared.saveUID(user!.uid);
				final profile = await getProfile(user!.uid);

				checkProgress(profile, context);
			} else {
				await auth.signOut();
			}
		} on FirebaseAuthException catch (e) {
			print(e);
			String title = "認証エラー";
			String message = "アカウントが存在しません";

			CustomDialogWidget dialog = CustomDialogWidget();
			dialog.showErrorDialog(context, title, message);
		}
		return null;
	}

	// プロフィール取得
	Future<ProfileModel?> getProfile(String uid) async {
		return await ProfileModel.getProfileByUid(uid);
	}

	// プロフィールの登録状況に応じて画面遷移切り替え
	void checkProgress(ProfileModel? profile, BuildContext context) {
		if (profile != null) {
			if (profile.username == null) {
				Navigator.push(
					context,
					MaterialPageRoute(builder: (context) => CreateProfile1(profile: profile))
				);
			} else if (profile.acount == null) {
				Navigator.push(
					context,
					MaterialPageRoute(builder: (context) => CreateProfile2(profile: profile))
				);
			} else {
				Navigator.pushNamed(
					context,
					"/mypage",
				);
			}
		} else {
			Navigator.push(
				context,
				MaterialPageRoute(builder: (context) => CreateNewAcount())
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black87,
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				title: const Text(
					"ログイン",
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
											hintText: "登録したメールアドレスを入力して下さい",
											hintStyle: TextStyle(color: Colors.grey),
											enabledBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.white70),
											),
											focusedBorder: UnderlineInputBorder(
												borderSide: BorderSide(color: Colors.lightBlue),
											),
										),
										validator: (value) {
											if (value == "") {
												return "メールアドレスが入力されていません";
											}
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
											hintText: "登録したパスワードを入力して下さい",
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
											if (value == "") {
												return "パスワードが入力されていません";
											}
										},
										onSaved: (value) {
											inputPass = value!;
										},
										style: TextStyle(color: Colors.white),
									),
									SizedBox(height: 10.0),
									Align(
										alignment: Alignment.center,
										child: ElevatedButton(
											child: Text(
												"ログイン",
												style: TextStyle(
													color: Colors.black,
												),
											),
											onPressed: () async {
												// 入力チェック
												if (_formKey.currentState!.validate()) {
													_formKey.currentState?.save();
													await handleSignIn(context);
												}
											},
										),
									),
								],
							),
						),
						SizedBox(height: 10.0),
						Padding(
							padding: EdgeInsets.all(16.0),
							child: SignInButton(
								text: "Googleでログイン",
								Buttons.google,
								onPressed: () async {
									await handleSignInGoogle(context);
								}
							),
						),
						SizedBox(height: 10.0),
						Divider(height: 1.0),
						SizedBox(height: 10.0),
						ElevatedButton(
							child: Text(
								"新規アカウント登録",
								style: TextStyle(
									color: Colors.black,
								),
							),
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => CreateNewAcount())
								);
							},
						),
					],
				),
			),
		);
	}
}

class Logout {
	FirebaseAuth auth = FirebaseAuth.instance;

	Future<void> signOut() async {
		final googleSignIn = GoogleSignIn();
		await googleSignIn.signOut();

		FirebaseAuth.instance.signOut();
	}
}

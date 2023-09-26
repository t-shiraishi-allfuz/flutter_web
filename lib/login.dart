import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'screen/mypage.dart';
import 'widget/loading.dart';
import 'utils/custom_shared.dart';

class Login extends StatelessWidget {
	FirebaseAuth auth = FirebaseAuth.instance;
	User? user;

	Future<User?> _handleSignIn(BuildContext context) async {
		GoogleAuthProvider authProvider = GoogleAuthProvider();

		try {
			await auth.signOut();
			final UserCredential authResult = await auth.signInWithPopup(authProvider);
			user = authResult.user;

			if (user != null) {
				await CustomShared.saveUID(user!.uid);

				Navigator.pushNamed(
					context,
					"/mypage",
				);
			} else {
				await auth.signOut();
			}
		} catch (error) {
			print("Error during Google sign in: $error");
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				title: const Text(
					"ログイン",
					style: TextStyle(
						color: Colors.white
					),
				),
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						SignInButton(
							Buttons.google,
							onPressed: () async {
								_handleSignIn(context);
							},
						),
					],
				),
			),
		);
	}
}

class AutoLogin extends StatelessWidget {
	FirebaseAuth auth = FirebaseAuth.instance;
	User? user;

	@override
	Widget build(BuildContext context) {
		return FutureBuilder(
			future: auth.authStateChanges().first,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return LoadingWidget();
				} else if (snapshot.hasData && snapshot.data != null) {
					return Mypage();
				} else {
					// ユーザーが未ログインの場合
					return Login();
				}
			},
		);
	}
}

class Logout {
	FirebaseAuth auth = FirebaseAuth.instance;

	static Future<void> signOut() async {
		final googleSignIn = GoogleSignIn();
		if (await googleSignIn.isSignedIn()) {
			await googleSignIn.signOut();
		}
		FirebaseAuth.instance.signOut();
	}
}

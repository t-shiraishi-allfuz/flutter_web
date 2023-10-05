import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'views/login.dart';
import 'views/create_acount.dart';
import 'views/mypage.dart';
import 'views/profile.dart';
import 'views/post_detail.dart';
import 'views/follow.dart';
import 'utils/custom_shared.dart';
import 'utils/post_manager.dart';
import 'utils/profile_manager.dart';
import 'widget/loading.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp(
		options: DefaultFirebaseOptions.currentPlatform,
	);
	setUrlStrategy(PathUrlStrategy());
	runApp(
		MultiProvider(
			providers: [
				ChangeNotifierProvider(
					create: (context) => PostManager(),
				),
				ChangeNotifierProvider(
					create: (context) => ProfileManager(),
				),
			],
			child: MyApp()
		),
	);
}

class MyApp extends StatefulWidget {
	const MyApp({super.key});

	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	late String routeName;
	Map<String, dynamic>? params;
	late Map<String, dynamic>? uriMap;
	late Future<Map<String, dynamic>?> uriFuture;

	@override
	void initState() {
		super.initState();

		uriFuture = _initUri();
	}

	Future<Map<String, dynamic>?> _initUri() async {
		final uri = await CustomShared.getUri();
		if (uri != null) {
			return uri as Map<String, dynamic>;
		} else {
			return null;
		}
	} 

	Route<dynamic> generateRoute(RouteSettings settings) {
		return _createRoute(settings);
	}

	PageRoute<dynamic> _createRoute(RouteSettings settings) {
		routeName = settings.name!;

		if (routeName == "/profile" || routeName == "/detail" || routeName == "/follow") {
			if (uriMap != null) {
				params = uriMap!["params"];
			} else {
				params = settings.arguments as Map<String, dynamic>;
				// キャッシュしておく
				CustomShared.saveUri(routeName!, params!);
			}
		}
		return _createPageRouteBuilder(settings);
	}

	PageRoute<dynamic> _createPageRouteBuilder(RouteSettings settings) {
		late Widget pageWidget = SizedBox.shrink();

		if (routeName == '/profile') {
			settings = RouteSettings(name: '/profile');
			pageWidget = Profile(arguments: params!);
		} else if (routeName == '/detail') {
			settings = RouteSettings(name: '/detail');
			pageWidget = PostDetail(arguments: params!);
		} else if (routeName == '/follow') {
			settings = RouteSettings(name: '/follow');
			pageWidget = Follow(arguments: params!);
		} else if (routeName == '/mypage') {
			settings = RouteSettings(name: '/mypage');
			pageWidget = Mypage();
		} else if (routeName == '/login') {
			settings = RouteSettings(name: '/login');
			pageWidget = Login();
		}

		return PageRouteBuilder(
			settings: settings,
			pageBuilder: (context, animation, secondaryAnimation) => pageWidget,
			transitionsBuilder: (context, animation, secondaryAnimation, child) {
				return child;
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<Map<String, dynamic>?>(
			future: uriFuture,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return LoadingWidget();
				} else if (snapshot.hasError) {
					return Center(child: Text("エラーが発生しました"));
				} else {
					uriMap = snapshot.data;

					return MaterialApp(
						debugShowCheckedModeBanner: false,
						title: 'Twitter風UI',
						theme: ThemeData(
							useMaterial3: true,
						),
						initialRoute: '/',
						onGenerateRoute: generateRoute,
						home: Login(),
					);
				}
			},
		);
	}
}

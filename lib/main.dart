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

import 'login.dart';
import 'screen/mypage.dart';
import 'screen/profile.dart';
import 'screen/post_detail.dart';
import 'utils/post_manager.dart';
import 'utils/custom_shared.dart';
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

		if (routeName == "/profile" || routeName == "/detail") {
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
							appBarTheme: AppBarTheme(
								backgroundColor: Colors.black87,
							),
							colorScheme: ColorScheme.fromSwatch().copyWith(
								primary: Colors.black87,
								secondary: Colors.black87,
								background: Colors.black87,
							),
							useMaterial3: true,
						),
						initialRoute: '/',
						onGenerateRoute: generateRoute,
						home: AutoLogin(),
					);
				}
			},
		);
	}
}

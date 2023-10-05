import 'package:flutter/material.dart';

// フッター
class FooterWidget extends StatelessWidget {
	final int currentIndex;
	final ValueChanged<int> onItemTapped;

	FooterWidget({
		required this.currentIndex,
		required this.onItemTapped,
	});

	@override
	Widget build(BuildContext context) {
		return BottomNavigationBar(
			backgroundColor: Colors.black87,
			currentIndex: currentIndex,
			items: <BottomNavigationBarItem>[
				BottomNavigationBarItem(
					icon: Icon(Icons.home),
					label: "ホーム"
				),
				BottomNavigationBarItem(
					icon: Icon(Icons.search),
					label: "検索",
				),
				BottomNavigationBarItem(
					icon: Icon(Icons.notifications),
					label: "通知",
				),
				BottomNavigationBarItem(
					icon: Icon(Icons.email),
					label: "メッセージ",
				),
			],
			selectedItemColor: Colors.lightBlue,
			unselectedItemColor: Colors.white,
			type: BottomNavigationBarType.fixed,
			onTap: onItemTapped,
		);
	}
}

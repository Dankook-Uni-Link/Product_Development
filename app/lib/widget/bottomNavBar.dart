import 'package:app/screen/home_screen.dart';
import 'package:app/screen/make_survey_screen.dart';
import 'package:app/screen/market_screen.dart';
import 'package:app/screen/my_page.dart';
import 'package:app/screen/raffle_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: const Color.fromARGB(255, 124, 124, 124),
      selectedLabelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.how_to_vote_sharp),
          label: '래플참여',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '마켓',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.poll),
          label: '설문 만들기',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget page;
        switch (index) {
          case 0:
            page = const MyPageScreen();
            break;
          case 1:
            page = const RaffleScreen();
            break;
          case 2:
            page = const HomeScreen();
            break;
          case 3:
            page = const MarketScreen();
            break;
          default:
            page = const MakeSurveyScreen();
            break;
        }
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}

import 'package:attendancerecords/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../setting/userOptions.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppIntroduction(),
    );
  }
}

class AppIntroduction extends StatefulWidget {
  const AppIntroduction({super.key});

  @override
  State<AppIntroduction> createState() => _AppIntroductionState();
}

class _AppIntroductionState extends State<AppIntroduction> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: 'First Page',
      body: 'This is the body of the first page',
      image: Image.asset(
        'assets/images/img1.jpeg',
        width: 350,
      ),
    ),
    PageViewModel(
      title: 'Second Page',
      body: 'This is the body of the second page',
      image: Center(
        child: Image.asset(
          'assets/images/img2.jpeg',
          width: 350,
        ),
      ),
    ),
    PageViewModel(
      title: 'Third Page',
      body: 'This is the body of the third page',
      image: Center(
        child: Image.asset(
          'assets/images/img3.jpeg',
          width: 350,
        ),
      ),
    ),
  ];

  void _onIntroEnd(context) {
    UserOptions.setDoneIntrocution(true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (e) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      // autoScrollDuration: 3000,
      pages: listPagesViewModel,
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () => _onIntroEnd(context),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}

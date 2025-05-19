import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home/widgets/home_button.dart';
import 'home/widgets/home_title.dart';
// import 'failure_chart_page.dart';
// import 'all_failures_page.dart';
// import 'deformat_page.dart';
import 'table_analysis_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitLayout(context);
          } else {
            return _buildLandscapeLayout(context);
          }
        }),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Lottie.asset(
            'assets/lottiefiles/main_screen.json',
            controller: _controller,
            repeat: true,
          ),
        ),
        const HomeTitle(title: 'Virok-KPI'),
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // HomeButton(
            //   text: 'Аналіз простоїв',
            //   onPressed: () =>
            //       _navigateToPage(context, const FailureChartPage()),
            // ),
            // const SizedBox(height: 20),
            // HomeButton(
            //   text: 'Всі простої',
            //   onPressed: () =>
            //       _navigateToPage(context, AllFailuresPage.allFailures()),
            // ),
            // const SizedBox(height: 20),
            // HomeButton(
            //   text: 'Деформат',
            //   onPressed: () => _navigateToPage(context, const DeformatPage()),
            // ),
            // const SizedBox(height: 20),
            HomeButton(
              text: 'Аналіз замовлень',
              onPressed: () =>
                  _navigateToPage(context, const TableAnalysisPage()),
            ),
            const SizedBox(height: 20),
            SettingsButton(
              text: 'Налаштування',
              onPressed: () => _navigateToPage(context, const SettingsPage()),
              // onPressed: () => () {},
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: HomeTitle(title: 'Virok-KPI'),
            ),
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'assets/lottiefiles/main_screen.json',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HomeButton(
            //   text: 'Аналіз простоїв',
            //   onPressed: () =>
            //       _navigateToPage(context, const FailureChartPage()),
            // ),
            // const SizedBox(height: 20),
            // HomeButton(
            //   text: 'Всі простої',
            //   onPressed: () =>
            //       _navigateToPage(context, AllFailuresPage.allFailures()),
            // ),
            // const SizedBox(height: 20),
            // HomeButton(
            //   text: 'Деформат',
            //   onPressed: () => _navigateToPage(context, const DeformatPage()),
            // ),
            // const SizedBox(height: 20),
            HomeButton(
              text: 'Аналіз замовлень',
              onPressed: () =>
                  _navigateToPage(context, const TableAnalysisPage()),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

import 'package:convertercalc_flutter/Pages/calc_page.dart';
import 'package:convertercalc_flutter/Pages/hist_page.dart';
import 'package:flutter/material.dart';

class CalcMainPage extends StatefulWidget {
  const CalcMainPage({super.key, required this.isDark});

  final bool isDark;

  @override
  State<CalcMainPage> createState() => _CalcMainPageState();
}

class _CalcMainPageState extends State<CalcMainPage> {
  int _selectPage = 0;

  // final List _pages = [CalcPage(isDark: widget.isDark,), const HistPage()];

  late List _pages;

  @override
  void initState() {
    super.initState();
    _pages = [CalcPage(isDark: widget.isDark,), const HistPage()];
  }

  void _navigateBottomBar(int page) {
    setState(() {
      _selectPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectPage],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.tertiary,
          useLegacyColorScheme: false,
          enableFeedback: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          currentIndex: _selectPage,
          selectedLabelStyle: const TextStyle(fontFamily: 'FiraCodeNerdFont'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'FiraCodeNerdFont'),
          onTap: _navigateBottomBar,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.calculate), label: 'Your Calc', ),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'Calc History'),
          ],
        ),
      ),
    );
  }
}

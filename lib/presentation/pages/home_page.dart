import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home/widgets/home_button.dart';
import 'home/widgets/home_title.dart';
// import 'failure_chart_page.dart';
// import 'all_failures_page.dart';
// import 'deformat_page.dart';
import 'table_analysis_page.dart';
import 'settings_page.dart';
import 'order_analysis_page.dart';
import 'order_reserve_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Theme.of(context).primaryColor.withOpacity(0.1),
          //     Colors.red,
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VIROK REPORT',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                // Text(
                //   'Система управління складом',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.grey[600],
                //   ),
                // ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildMenuCard(
                        context: context,
                        title: 'Відвантажені замовлення',
                        icon: Icons.analytics_outlined,
                        // color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TableAnalysisPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Коригування',
                        icon: Icons.inventory_2_outlined,
                        // color: Colors.green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderAnalysisPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Резерви',
                        icon: Icons.lock_outline,
                        // color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderReservePage(),
                          ),
                        ),
                      ),
                      // Add more menu cards here as needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    Color color = Colors.red,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

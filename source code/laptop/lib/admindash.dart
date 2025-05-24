import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop/drawer.dart';
import 'package:laptop/bottambar.dart';
import 'package:laptop/adminorder.dart';
import 'package:laptop/admincategadd.dart';
import 'package:laptop/profile.dart';
import 'package:laptop/updateprofile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Color darkPurple = const Color(0xFF2E003E);
  final Color offWhite = const Color(0xFFF4F4F8);
  final Color accentPurple = const Color(0xFFB388EB);

  int _currentIndex = 1;
  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int cancelledOrders = 0;

  @override
  void initState() {
    super.initState();
    _calculateOrders();
  }

  Future<void> _calculateOrders() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('Orders').get();

    totalOrders = ordersSnapshot.docs.length;
    pendingOrders =
        ordersSnapshot.docs
            .where((doc) => doc['orderStatus'] == 'pending')
            .length;
    deliveredOrders =
        ordersSnapshot.docs
            .where((doc) => doc['orderStatus'] == 'delivered')
            .length;
    cancelledOrders =
        ordersSnapshot.docs
            .where((doc) => doc['orderStatus'] == 'canceled')
            .length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: darkPurple,
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.black26,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/l2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmall = constraints.maxWidth < 550;
                      return isSmall
                          ? Column(
                            children: [
                              buildInfoCard(
                                Icons.shopping_bag,
                                'Total Orders',
                                totalOrders.toString(),
                              ),
                              const SizedBox(height: 16),
                              buildInfoCard(
                                Icons.access_time,
                                'Pending Orders',
                                pendingOrders.toString(),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: buildInfoCard(
                                  Icons.shopping_bag,
                                  'Total Orders',
                                  totalOrders.toString(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInfoCard(
                                  Icons.access_time,
                                  'Pending Orders',
                                  pendingOrders.toString(),
                                ),
                              ),
                            ],
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmall = constraints.maxWidth < 550;
                      return isSmall
                          ? Column(
                            children: [
                              buildInfoCard(
                                Icons.local_shipping,
                                'Delivered Orders',
                                deliveredOrders.toString(),
                              ),
                              const SizedBox(height: 16),
                              buildInfoCard(
                                Icons.cancel,
                                'Cancelled Orders',
                                cancelledOrders.toString(),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: buildInfoCard(
                                  Icons.local_shipping,
                                  'Delivered Orders',
                                  deliveredOrders.toString(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInfoCard(
                                  Icons.cancel,
                                  'Cancelled Orders',
                                  cancelledOrders.toString(),
                                ),
                              ),
                            ],
                          );
                    },
                  ),
                  const SizedBox(height: 30),
                  buildChartCard(),
                  const SizedBox(height: 30),
                  buildTopBuyersCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: CustomBottomAppBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderListPage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
              );
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Profile()));
            }
          },
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String label, String count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, offWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentPurple, Colors.deepPurple],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentPurple.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 16, color: darkPurple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [offWhite, const Color.fromARGB(255, 187, 147, 233)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📈 Orders Overview",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, _) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: darkPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return Text(
                              'Total',
                              style: TextStyle(fontSize: 12, color: darkPurple),
                            );
                          case 1:
                            return Text(
                              'Pending',
                              style: TextStyle(fontSize: 12, color: darkPurple),
                            );
                          case 2:
                            return Text(
                              'Delivered',
                              style: TextStyle(fontSize: 12, color: darkPurple),
                            );
                          case 3:
                            return Text(
                              'Cancelled',
                              style: TextStyle(fontSize: 12, color: darkPurple),
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, totalOrders.toDouble()),
                      FlSpot(1, pendingOrders.toDouble()),
                      FlSpot(2, deliveredOrders.toDouble()),
                      FlSpot(3, cancelledOrders.toDouble()),
                    ],
                    isCurved: true,
                    color: accentPurple,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: accentPurple.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopBuyersCard() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('Orders').get(),
      builder: (context, ordersSnapshot) {
        if (!ordersSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Count orders per userId
        Map<String, int> userOrderCount = {};
        for (var doc in ordersSnapshot.data!.docs) {
          String userId = doc['userId'];
          userOrderCount[userId] = (userOrderCount[userId] ?? 0) + 1;
        }

        // Sort by order count and take top 10
        List<MapEntry<String, int>> sortedEntries =
            userOrderCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        List<MapEntry<String, int>> topUsers = sortedEntries.take(10).toList();

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('User').get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Map of userId -> userData (only where role == 'user')
            Map<String, Map<String, dynamic>> userDataMap = {
              for (var doc in userSnapshot.data!.docs)
                if ((doc.data() as Map<String, dynamic>)['role'] == 'user')
                  doc.id: doc.data() as Map<String, dynamic>,
            };

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, offWhite],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "👑 Top Buyers",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...topUsers.map((entry) {
                    final userId = entry.key;
                    final orderCount = entry.value;
                    final user = userDataMap[userId];

                    if (user == null) return const SizedBox.shrink();

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: accentPurple,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['UserName'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        subtitle: Text(
                          "$orderCount orders",
                          style: TextStyle(color: darkPurple),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

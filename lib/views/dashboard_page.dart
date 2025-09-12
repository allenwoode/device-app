import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  //bool _isRefreshing = false;
  bool _shouldAnimateCards = true;

  Future<void> _onRefresh() async {
    setState(() {
      //_isRefreshing = true;
      _shouldAnimateCards = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _shouldAnimateCards = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    // setState(() {
    //   _isRefreshing = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '浙江杰马电子科技',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DashboardCard(
                title: '设备',
                total: 50,
                primaryLabel: '在线',
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: '离线',
                secondaryValue: 10,
                secondaryColor: Colors.grey,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: '使用率分布',
                total: null,
                primaryLabel: '>60%',
                primaryValue: 30,
                primaryColor: Colors.green,
                secondaryLabel: '<10%',
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: '今日告警',
                total: 50,
                primaryLabel: '报警',
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: '严重',
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
              const SizedBox(height: 16),
              DashboardCard(
                title: '操作日志',
                total: 50,
                primaryLabel: '设备上报',
                primaryValue: 40,
                primaryColor: Colors.green,
                secondaryLabel: '平台下发',
                secondaryValue: 10,
                secondaryColor: Colors.red,
                shouldAnimate: _shouldAnimateCards,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


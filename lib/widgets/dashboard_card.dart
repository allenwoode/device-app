import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final int? total;
  final String primaryLabel;
  final int primaryValue;
  final Color primaryColor;
  final String secondaryLabel;
  final int secondaryValue;
  final Color secondaryColor;
  final bool shouldAnimate;

  const DashboardCard({
    super.key,
    required this.title,
    required this.total,
    required this.primaryLabel,
    required this.primaryValue,
    required this.primaryColor,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.secondaryColor,
    this.shouldAnimate = true,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.shouldAnimate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _animationController.reset();
      _animationController.forward();
    } else if (!widget.shouldAnimate && oldWidget.shouldAnimate) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.total != null) ...[
                      Text(
                        '${widget.total}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildCircularChart(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.primaryLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.primaryValue}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.secondaryLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.secondaryValue}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularChart() {
    final total = widget.primaryValue + widget.secondaryValue;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: (1.0 - _animation.value) * 2 * 3.14159,
          child: Opacity(
            opacity: _animation.value,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 20,
                    startDegreeOffset: -90,
                    sections: total > 0 ? [
                      PieChartSectionData(
                        color: widget.primaryColor,
                        value: widget.primaryValue.toDouble(),
                        title: '',
                        radius: 20,
                        borderSide: BorderSide.none,
                      ),
                      PieChartSectionData(
                        color: widget.secondaryColor,
                        value: widget.secondaryValue.toDouble(),
                        title: '',
                        radius: 20,
                        borderSide: BorderSide.none,
                      ),
                    ] : [
                      PieChartSectionData(
                        color: Colors.grey[300]!,
                        value: 1.0,
                        title: '',
                        radius: 20,
                        borderSide: BorderSide.none,
                      ),
                    ],
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                ),
            ),
          ),
        );
      },
    );
  }
}
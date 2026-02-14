import 'package:flutter/material.dart';

/// Skeleton loader with shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for job loading state
class SkeletonJobCard extends StatelessWidget {
  const SkeletonJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SkeletonLoader(width: 48, height: 48, borderRadius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(height: 16, width: MediaQuery.of(context).size.width * 0.4),
                  const SizedBox(height: 8),
                  SkeletonLoader(height: 12, width: MediaQuery.of(context).size.width * 0.25),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Flexible(child: SkeletonLoader(width: 60, height: 20, borderRadius: 6)),
                      SizedBox(width: 8),
                      Flexible(child: SkeletonLoader(width: 40, height: 20, borderRadius: 6)),
                    ],
                  ),
                ],
              ),
            ),
            const SkeletonLoader(width: 80, height: 28, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}

/// Skeleton Kanban column
class SkeletonKanbanColumn extends StatelessWidget {
  const SkeletonKanbanColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                SkeletonLoader(width: 80, height: 14),
                Spacer(),
                SkeletonLoader(width: 24, height: 20, borderRadius: 8),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                SkeletonJobCard(),
                SkeletonJobCard(),
                SkeletonJobCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

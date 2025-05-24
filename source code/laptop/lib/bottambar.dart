import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomAppBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF4A148C); // Dark Purple
    final Color highlightColor = Colors.white;
    final Color inactiveColor = Colors.white70;

    List<IconData> icons = [
      Icons.shopping_bag, // 0 = Orders
      Icons.home,         // 1 = Home
      Icons.person,       // 2 = Profile
    ];

    int leftIndex, centerIndex, rightIndex;
    switch (currentIndex) {
      case 0:
        centerIndex = 1;  // Home icon in the center when orders is selected
        leftIndex = 0;    // Orders icon on the left
        rightIndex = 2;   // Profile icon on the right
        break;
      case 1:
        centerIndex = 1;  // Home icon in the center when home is selected
        leftIndex = 0;    // Orders icon on the left
        rightIndex = 2;   // Profile icon on the right
        break;
      case 2:
        centerIndex = 1;  // Home icon in the center when profile is selected
        leftIndex = 0;    // Orders icon on the left
        rightIndex = 2;   // Profile icon on the right
        break;
      default:
        centerIndex = 1;  // Default to Home in the center
        leftIndex = 0;    // Orders icon on the left
        rightIndex = 2;   // Profile icon on the right
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: icons[leftIndex],
                index: leftIndex,
                onTap: onTap,
                color: inactiveColor,
              ),
              _buildNavItem(
                icon: icons[rightIndex],
                index: rightIndex,
                onTap: onTap,
                color: inactiveColor,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 15,
          child: GestureDetector(
            onTap: () => onTap(centerIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: highlightColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icons[centerIndex],
                size: 30,
                color: backgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required Function(int) onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}

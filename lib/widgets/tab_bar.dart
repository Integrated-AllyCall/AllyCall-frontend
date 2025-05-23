import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/pepicons.dart';
import 'package:iconify_flutter/icons/gg.dart';

class CustomTabBar extends StatefulWidget {
  final TabController tabController;
  const CustomTabBar({super.key, required this.tabController});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const svgPhone = '''
<svg width="20" height="25" viewBox="0 0 20 25" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9.58327 8.43654L7.58468 10.2297C7.84888 11.134 8.21791 12.0043 8.68427 12.8228C9.17071 13.6354 9.75687 14.3839 10.4291 15.051L13.0174 14.2535C14.4674 13.8064 16.0503 14.2655 17.0145 15.4135L18.4887 17.168C19.0855 17.8723 19.3848 18.7813 19.323 19.7025C19.2612 20.6236 18.8432 21.4845 18.1576 22.1028C15.753 24.2971 12.0507 25.039 9.27877 22.8616C6.84148 20.9446 4.78 18.593 3.19843 15.9258C1.61285 13.2717 0.551271 10.338 0.0712686 7.28379C-0.460398 3.84729 2.05535 1.09713 5.19219 0.159461C7.06269 -0.401206 9.05885 0.560628 9.74518 2.35379L10.5548 4.46838C11.0864 5.86038 10.7046 7.43121 9.58327 8.43654Z" fill="white"/>
</svg>
''';

    const svgBulb = '''
<svg width="20" height="21" viewBox="0 0 20 21" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M1 10.5H2M10 1.125V2.16667M18 10.5H19M3.6 3.83333L4.3 4.5625M16.4 3.83333L15.7 4.5625M7.7 15.7083H12.3M7 14.6667C6.16047 14.0108 5.54033 13.0964 5.22743 12.053C4.91453 11.0095 4.92473 9.89002 5.25658 8.85298C5.58844 7.81594 6.22512 6.91395 7.07645 6.27478C7.92778 5.63561 8.95059 5.29167 10 5.29167C11.0494 5.29167 12.0722 5.63561 12.9236 6.27478C13.7749 6.91395 14.4116 7.81594 14.7434 8.85298C15.0753 9.89002 15.0855 11.0095 14.7726 12.053C14.4597 13.0964 13.8395 14.0108 13 14.6667C12.6096 15.0693 12.3156 15.5619 12.1419 16.1048C11.9681 16.6477 11.9195 17.2256 12 17.7917C12 18.3442 11.7893 18.8741 11.4142 19.2648C11.0391 19.6555 10.5304 19.875 10 19.875C9.46957 19.875 8.96086 19.6555 8.58579 19.2648C8.21071 18.8741 8 18.3442 8 17.7917C8.08046 17.2256 8.03185 16.6477 7.85813 16.1048C7.6844 15.5619 7.39043 15.0693 7 14.6667Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

    final selected = widget.tabController.index;
    const selectedColor = Color(0xFFFAA6A8);
    const unselectedColor = Color(0xFF8A8A8A);

    Color getColor(int index) => selected == index ? selectedColor : unselectedColor;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: TabBar(
                controller: widget.tabController,
                indicator: const DotIndicator(color: selectedColor),
                tabs: [
                  Tab(icon: Icon(Icons.home_filled, size: 30, color: getColor(0))),
                  Tab(icon: Iconify(Pepicons.map, size: 30, color: getColor(1))),
                  const SizedBox(width: 5), // Floating button placeholder
                  Tab(icon: Iconify(svgBulb, size: 30, color: getColor(3))),
                  Tab(icon: Iconify(Gg.profile, size: 30, color: getColor(4))),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: selected == 2 ? -30 : -25,
          child: GestureDetector(
            onTap: () => widget.tabController.animateTo(2),
            child: Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Iconify(svgPhone, size: 40, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class DotIndicator extends Decoration {
  final Color color;

  const DotIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(color: color);
  }
}

class _DotPainter extends BoxPainter {
  final Color color;

  _DotPainter({required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint =
        Paint()
          ..color = color
          ..isAntiAlias = true;

    final Offset circleOffset = Offset(
      offset.dx + configuration.size!.width / 2,
      offset.dy + configuration.size!.height - 18,
    );

    canvas.drawCircle(circleOffset, 3, paint);
  }
}

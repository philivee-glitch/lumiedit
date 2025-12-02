import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/editor_constants.dart';

class ToolTabBar extends StatelessWidget {
  final EditorTab selectedTab;
  final ValueChanged<EditorTab> onTabSelected;

  const ToolTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: EditorTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: EditorConstants.shortAnimation,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

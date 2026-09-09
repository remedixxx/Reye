import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MiniCountdownWidget extends StatelessWidget {
  const MiniCountdownWidget({
    required this.label,
    this.openMainTooltip,
    this.onOpenMain,
    this.draggable = false,
    super.key,
  });

  final String label;
  final String? openMainTooltip;
  final VoidCallback? onOpenMain;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final countdown = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.visibility_outlined,
          size: 16,
          color: colorScheme.primary,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 8),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (draggable)
              DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: countdown,
                ),
              )
            else
              countdown,
            if (onOpenMain != null) ...[
              const SizedBox(width: 4),
              Semantics(
                button: true,
                label: openMainTooltip,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onOpenMain,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                        color: colorScheme.primary,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/theme.dart';

class CheckInStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const CheckInStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          return _stepDot(stepIndex, steps[stepIndex]);
        } else {
          final lineIndex = (index - 1) ~/ 2;
          return _stepLine(lineIndex);
        }
      }),
    );
  }

  Widget _stepDot(int index, String label) {
    bool active = currentStep >= index;
    bool isCurrent = currentStep == index;

    Widget dot = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isCurrent ? 36 : 30,
      height: isCurrent ? 36 : 30,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: active
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                  key: ValueKey('check'),
                )
              : Text(
                  "${index + 1}",
                  key: ValueKey('num$index'),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );

    return Column(
      children: [
        dot,
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 12,
            color: active ? AppTheme.primary : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Widget _stepLine(int index) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        decoration: BoxDecoration(
          color: currentStep > index ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class CheckInStepCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Widget content;

  const CheckInStepCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          content,
        ],
      ),
    );
  }
}

class CheckInSuccessView extends StatelessWidget {
  final VoidCallback onDismiss;

  const CheckInSuccessView({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ZoomIn(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElasticIn(
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accent,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "You're In!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Attendance marked successfully.",
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                ),
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

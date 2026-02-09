import 'package:flutter/material.dart';

class PasswordRuleData {
  const PasswordRuleData({
    required this.label,
    required this.isSatisfied,
  });

  final String label;
  final bool isSatisfied;
}

class PasswordRules extends StatelessWidget {
  const PasswordRules({
    super.key,
    required this.title,
    required this.rules,
  });

  final String title;
  final List<PasswordRuleData> rules;

  @override
  Widget build(BuildContext context) {
    final unsatisfied = rules.where((rule) => !rule.isSatisfied).toList();
    if (unsatisfied.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ...unsatisfied.map(
          (rule) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8),
                const SizedBox(width: 8),
                Expanded(child: Text(rule.label)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/session_model.dart';
import '../../../l10n/app_localizations.dart';

class SessionCard extends StatelessWidget {
  final SessionModel sessionModel;
  final void Function()? onTap;

  const SessionCard({super.key, required this.sessionModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      onTap: onTap,

      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: AppLocalizations.of(context)!.sessionName, value: sessionModel.title ?? ''),

          _InfoRow(
            label: AppLocalizations.of(context)!.description,
            value: sessionModel.description ?? '',
          ),

          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  label: AppLocalizations.of(context)!.time,
                  value: sessionModel.time ?? AppLocalizations.of(context)!.noTimeAdded,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  label: AppLocalizations.of(context)!.date,
                  value:
                      sessionModel.date?.toIso8601String().split('T').first ??
                      '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.mediumGrey),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

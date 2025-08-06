import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/widgets/rounded_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/session_model.dart';

class CalendarView extends StatefulWidget {
  final List<SessionModel> sessionDates;

  const CalendarView({super.key, required this.sessionDates});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final Map<DateTime, SessionModel> _markedSessions;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _markedSessions = {
      for (var session in widget.sessionDates)
        if (session.date != null)
          DateTime(session.date!.year, session.date!.month, session.date!.day):
              session,
    };
  }

  bool _isMarked(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _markedSessions.containsKey(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return RoundedContainer(
      blur: true,
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(3000, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          final normalized = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );

          final session = _markedSessions[normalized];

          if (session != null) {
            // navigatorKey.currentState!.push(
            //   MaterialPageRoute(
            //     builder: (context) => SessionDetailsPage(sessionId: session.id),
            //   ),
            // );
          }
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          todayTextStyle: textTheme.bodySmall!.copyWith(
            color: AppColors.pureWhite,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: textTheme.bodySmall!.copyWith(
            color: AppColors.pureWhite,
          ),
          defaultTextStyle: textTheme.bodySmall!,
          outsideTextStyle: textTheme.bodySmall!,
          weekendTextStyle: textTheme.bodySmall!,
          weekNumberTextStyle: textTheme.bodySmall!,
          holidayTextStyle: textTheme.bodySmall!,
          withinRangeTextStyle: textTheme.bodySmall!,
          rangeEndTextStyle: textTheme.bodySmall!,
          rangeStartTextStyle: textTheme.bodySmall!,
          disabledTextStyle: textTheme.bodySmall!,
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: textTheme.bodyMedium!,
          formatButtonVisible: false,
          leftChevronIcon: Icon(
            Provider.of<LocaleProvider>(context).locale == Locale('ar')
                ? Iconsax.arrow_right
                : Iconsax.arrow_square_left,
          ),
          rightChevronIcon: Icon(
            Provider.of<LocaleProvider>(context).locale == Locale('ar')
                ? Iconsax.arrow_square_left
                : Iconsax.arrow_right,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: textTheme.bodySmall!,
          weekendStyle: textTheme.bodySmall!,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (_isMarked(day)) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

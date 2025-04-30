import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
    _updateDateRange();
  }

  @override
  void didUpdateWidget(CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update focused day if selectedDate prop changes externally
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _focusedDay = widget.selectedDate;
      });
    }
    // Recalculate date range in case the current date changes significantly (though unlikely in short sessions)
    _updateDateRange(); 
  }

  void _updateDateRange() {
     final now = DateTime.now();
     final normalizedNow = DateTime(now.year, now.month, now.day);
     _firstDay = normalizedNow.subtract(const Duration(days: 7));
     _lastDay = normalizedNow.add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TableCalendar(
        locale: 'en_US',
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay, // Use state variable for focus
        selectedDayPredicate: (day) {
          // Use `isSameDay` for accurate comparison ignoring time
          return isSameDay(widget.selectedDate, day);
        },
        calendarFormat: CalendarFormat.week, // Show only one week
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
             CalendarFormat.week: 'Week', // Only allow week format
        },
        // --- Styling --- 
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false, // Hide format button (already set to week only)
          titleTextStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
        ),
        calendarStyle: CalendarStyle(
          // Selected day style
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          // Today style
          todayDecoration: BoxDecoration(
            color: Colors.transparent, // No background fill
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
          todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          // Weekend style
          weekendTextStyle: const TextStyle(color: Colors.redAccent),
          // Outside month days (not relevant for week view, but good practice)
          outsideDaysVisible: false, 
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
           // Style for Mon, Tue, etc.
           weekendStyle: TextStyle(color: Colors.redAccent), // Style weekend days header
        ),
        // --- Callbacks --- 
        onDaySelected: (selectedDay, focusedDay) {
          // Check constraints again just in case (though first/last day should handle it)
          final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          if (normalizedSelectedDay.isBefore(_firstDay) || normalizedSelectedDay.isAfter(_lastDay)) {
            return; // Should not happen if firstDay/lastDay are set correctly
          }
          
          // Only call callback if the day actually changed
          if (!isSameDay(widget.selectedDate, selectedDay)) {
             widget.onDateSelected(selectedDay); // Pass the selected day
             // Update focused day internally when a day is selected
             setState(() {
               _focusedDay = focusedDay; 
             });
          }
        },
        onPageChanged: (focusedDay) {
          // Update focused day when user swipes between weeks
          setState(() {
             _focusedDay = focusedDay;
          });
        },
      ),
    );
  }
}


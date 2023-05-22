

class DateTimeManager {

  /// 이 함수는 현재 날짜로 부터 해당월의 몇번째 주인지를 계산하여 반환합니다.
  static int getWeekOfMonth({DateTime? date}) {
    date ??= DateTime.now();

    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int weekday = firstDayOfMonth.weekday;
    int firstWeekStart = 1 + ((8 - weekday) % 7);

    int daysSinceFirstWeekStart = date.day - firstWeekStart;
    int currentWeek = 1 + (daysSinceFirstWeekStart / 7).floor();

    return currentWeek;
  }
}
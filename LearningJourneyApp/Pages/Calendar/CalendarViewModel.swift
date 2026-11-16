//
//  CalendarViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class CalendarViewModel {

    // استخدام نفس بيانات Activity في جميع الصفحات
    private let activityViewModel = ActivityViewModel.shared

    // بداية الأسبوع يوم الأحد
    private var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }()

    // عرض الأشهر من يناير حتى الشهر الحالي
    var months: [Date] {

        let today = Date()
        let year = calendar.component(.year, from: today)

        guard let january = calendar.date(
            from: DateComponents(
                year: year,
                month: 1,
                day: 1
            )
        ) else {
            return []
        }

        let currentMonth = calendar.component(
            .month,
            from: today
        )

        return (0..<currentMonth).compactMap {
            calendar.date(
                byAdding: .month,
                value: $0,
                to: january
            )
        }
    }

    // عنوان الشهر والسنة
    func monthTitle(for date: Date) -> String {

        date.formatted(
            .dateTime
                .month(.wide)
                .year()
                .locale(Locale(identifier: "en_US"))
        )
    }

    // أسماء أيام الأسبوع
    var weekdays: [String] {
        ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    }

    // إنشاء أيام الشهر مع الفراغات الأولى
    func days(for month: Date) -> [Date?] {

        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: month
        ),
        let firstDay = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: month
            )
        ) else {
            return []
        }

        let offset = (
            calendar.component(.weekday, from: firstDay) - 1 + 7
        ) % 7

        let emptyDays = Array<Date?>(
            repeating: nil,
            count: offset
        )

        let monthDays: [Date?] = range.compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            )
        }

        return emptyDays + monthDays
    }

    // جلب حالة اليوم من ActivityViewModel
    func status(for date: Date) -> ActivityStatus? {

        // عدم عرض تسجيلات مستقبلية
        guard calendar.startOfDay(for: date)
                <= calendar.startOfDay(for: Date()) else {
            return nil
        }

        return activityViewModel.status(on: date)
    }

    // تحديد اليوم الحالي
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
}

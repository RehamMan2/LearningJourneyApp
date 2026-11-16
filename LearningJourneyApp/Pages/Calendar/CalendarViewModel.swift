//
//  CalendarViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//

import Foundation
import Observation

@Observable
final class CalendarViewModel {

    // Calendar uses Sunday as the first weekday.
    private var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }()

    // Recorded days shared with the calendar.
    var learningDays: [LearningDay] = []

    // Returns all months from January to the current month.
    var months: [Date] {
        let today = Date()
        let year = calendar.component(.year, from: today)

        guard let january = calendar.date(
            from: DateComponents(year: year, month: 1, day: 1)
        ) else {
            return []
        }

        let currentMonth = calendar.component(.month, from: today)

        return (0..<currentMonth).compactMap {
            calendar.date(byAdding: .month, value: $0, to: january)
        }
    }

    // Formats the month title, such as January 2026.
    func monthTitle(for date: Date) -> String {
        date.formatted(
            .dateTime
                .month(.wide)
                .year()
                .locale(Locale(identifier: "en_US"))
        )
    }

    // Returns the weekday labels.
    var weekdays: [String] {
        ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    }

    // Returns empty positions followed by the days of the month.
    func days(for month: Date) -> [Date?] {
        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: month
        ),
        let firstDay = calendar.date(
            from: calendar.dateComponents([.year, .month], from: month)
        ) else {
            return []
        }

        let offset = (calendar.component(.weekday, from: firstDay) - 1 + 7) % 7

        let emptyDays = Array<Date?>(repeating: nil, count: offset)

        let monthDays: [Date?] = range.compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            )
        }

        return emptyDays + monthDays
    }

    // Finds the recorded status of a specific day.
    func status(for date: Date) -> LearningDayStatus? {
        learningDays.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }?.status
    }

    // Checks whether a date is today.
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
}


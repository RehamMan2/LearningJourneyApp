//
//  ActivityViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//



import Foundation
import Observation

// Learning goal duration and Freeze allowance
enum GoalDuration: String, Codable, CaseIterable, Identifiable {

    case week, month, year

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var freezeLimit: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
}

// Possible activity statuses
enum ActivityStatus: String, Codable {
    case learned
    case frozen
}

// Record for each logged day
struct ActivityRecord: Codable {
    let date: Date
    let timestamp: Date
    let status: ActivityStatus
}

@MainActor
@Observable
final class ActivityViewModel {

    // Shared instance across pages
    static let shared = ActivityViewModel()

    // Activity records
    var records: [ActivityRecord] = []

    // Current learning goal
    private(set) var learningTopic = "Swift"
    private(set) var duration: GoalDuration = .week

    // Goal start and reset dates
    private(set) var goalStartedAt = Date()
    private(set) var resetAt = Date.distantPast

    // Calendar and storage
    private let calendar = Calendar.current
    private let storageKey = "learning.activity.v3"

    // Saved data structure
    private struct SavedData: Codable {
        let records: [ActivityRecord]
        let duration: GoalDuration
        let goalStartedAt: Date
        let resetAt: Date
        let learningTopic: String?
    }

    // Load saved data or create mock data
    init() {
        if !load() {
            addMockData()
            save()
        }
    }

    // Get the beginning of a day
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Get the status of a specific day
    func status(on date: Date) -> ActivityStatus? {

        records.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
            && $0.timestamp >= resetAt
        }?.status
    }

    // Get all dates in the current week
    func weekDates(at now: Date) -> [Date] {

        guard let week = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) else {
            return [startOfDay(now)]
        }

        return (0..<7).compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day,
                to: week.start
            )
        }
    }

    // Create default activity records
    private func addMockData() {

        let now = Date()

        guard let week = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) else {
            return
        }

        //
        let mockDays: [(Int, ActivityStatus)] = [
            (1, .learned)
        ]

        for (weekday, status) in mockDays {

            var components = calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: week.start
            )

            components.weekday = weekday

            guard let date = calendar.date(from: components),
                  date <= now else {
                continue
            }

            records.append(
                ActivityRecord(
                    date: startOfDay(date),
                    timestamp: date,
                    status: status
                )
            )
        }

        if let firstDate = records.map(\.timestamp).min() {
            goalStartedAt = firstDate
        }
    }

    // Get the current Freeze allowance period
    private func period(containing date: Date) -> DateInterval? {

        let component: Calendar.Component

        switch duration {
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        case .year:
            component = .year
        }

        return calendar.dateInterval(
            of: component,
            for: date
        )
    }

    // Calculate used Freeze Days
    func usedFreezes(at now: Date) -> Int {

        guard let currentPeriod = period(
            containing: now
        ) else {
            return 0
        }

        // Compare dates from the start of the day
        let periodStart = max(
            currentPeriod.start,
            startOfDay(goalStartedAt)
        )

        return records.filter { record in

            record.status == .frozen
            && record.date >= periodStart
            && record.date < currentPeriod.end
            && record.timestamp >= resetAt

        }.count
    }

    // Calculate remaining Freeze Days
    func remainingFreezes(at now: Date) -> Int {

        max(
            0,
            duration.freezeLimit - usedFreezes(at: now)
        )
    }

    // Check whether Learned can be selected
    func canLog(at now: Date) -> Bool {
        status(on: now) != .frozen
    }

    // Check whether Freeze can be selected
    func canFreeze(at now: Date) -> Bool {

        // Allow undoing today's Freeze
        if status(on: now) == .frozen {
            return true
        }

        // Allow Freeze only for an empty day
        return status(on: now) == nil
            && remainingFreezes(at: now) > 0
    }

    // Log Learned or undo it
    func toggleLearned(at now: Date = Date()) {

        let today = startOfDay(now)

        switch status(on: now) {

        case .learned:

            // Remove today's Learned record
            records.removeAll { record in
                calendar.isDate(
                    record.date,
                    inSameDayAs: today
                )
                && record.status == .learned
                && record.timestamp >= resetAt
            }

        case .frozen:

            // Cannot log Learned on a frozen day
            return

        case nil:

            // Add today's Learned record
            records.append(
                ActivityRecord(
                    date: today,
                    timestamp: now,
                    status: .learned
                )
            )
        }

        save()
    }

    // Log Freeze or undo it
    func toggleFreeze(at now: Date = Date()) {

        let today = startOfDay(now)

        switch status(on: now) {

        case .frozen:

            // Undo Freeze and restore the allowance
            records.removeAll { record in
                calendar.isDate(
                    record.date,
                    inSameDayAs: today
                )
                && record.status == .frozen
                && record.timestamp >= resetAt
            }

        case .learned:

            // Cannot Freeze an already learned day
            return

        case nil:

            // Check available Freeze allowance
            guard remainingFreezes(at: now) > 0 else {
                return
            }

            // Add today's Freeze record
            records.append(
                ActivityRecord(
                    date: today,
                    timestamp: now,
                    status: .frozen
                )
            )
        }

        // Persist updated records
        save()
    }

    // Calculate the our deadline
    private func deadline(after date: Date) -> Date? {

        guard let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay(date)
        ) else {
            return nil
        }

        // 32 hours from the start of the next day
        return nextDay.addingTimeInterval(
            32 * 60 * 60
        )
    }

    // Calculate current Streak
    func streak(at now: Date) -> Int {

        let sortedRecords = records
            .filter { record in
                record.timestamp <= now
                && record.timestamp >= resetAt
            }
            .sorted {
                $0.timestamp < $1.timestamp
            }

        guard let lastRecord = sortedRecords.last,
              let lastDeadline = deadline(
                after: lastRecord.date
              ),
              now <= lastDeadline else {
            return 0
        }

        var count = 1
        var newerRecord = lastRecord

        for olderRecord in sortedRecords.dropLast().reversed() {

            guard let limit = deadline(
                after: olderRecord.date
            ),
            newerRecord.timestamp <= limit else {
                break
            }

            count += 1
            newerRecord = olderRecord
        }

        return count
    }

    // Update the learning goal
    @discardableResult
    func updateGoal(
        topic newTopic: String,
        duration newDuration: GoalDuration,
        at now: Date = Date()
    ) -> Bool {

        let cleanedTopic = newTopic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // Prevent empty learning topics
        guard !cleanedTopic.isEmpty else {
            return false
        }

        // Detect actual changes
        let topicChanged = cleanedTopic != learningTopic
        let durationChanged = newDuration != duration

        guard topicChanged || durationChanged else {
            return false
        }

        // Update goal information
        learningTopic = cleanedTopic
        duration = newDuration

        // Reset Streak and Freeze records
        goalStartedAt = now
        resetAt = now
        records.removeAll()

        save()

        return true
    }

    // Save activity data
    private func save() {

        let savedData = SavedData(
            records: records,
            duration: duration,
            goalStartedAt: goalStartedAt,
            resetAt: resetAt,
            learningTopic: learningTopic
        )

        guard let encodedData = try? JSONEncoder().encode(
            savedData
        ) else {
            return
        }

        UserDefaults.standard.set(
            encodedData,
            forKey: storageKey
        )
    }

    // Load previously saved activity data
    @discardableResult
    private func load() -> Bool {

        guard let storedData = UserDefaults.standard.data(
            forKey: storageKey
        ),
        let decodedData = try? JSONDecoder().decode(
            SavedData.self,
            from: storedData
        ) else {
            return false
        }

        records = decodedData.records
        duration = decodedData.duration
        goalStartedAt = decodedData.goalStartedAt
        resetAt = decodedData.resetAt
        learningTopic = decodedData.learningTopic ?? "Swift"

        return true
    }
}

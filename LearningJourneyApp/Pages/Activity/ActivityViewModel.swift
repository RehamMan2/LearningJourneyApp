//
//  ActivityViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//






import Foundation
import Observation

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

    // Shared ViewModel across pages
    static let shared = ActivityViewModel()

    // Activity records
    var records: [ActivityRecord] = []

    // Current learning goal
    private(set) var learningTopic = "Swift"
    private(set) var duration: LearningDuration = .week

    // Goal dates
    private(set) var goalStartedAt = Date()
    private(set) var resetAt = Date.distantPast

    // Calendar and storage
    private let calendar = Calendar.current
    private let storageKey = "learning.activity.v3"

    // Saved data structure
    private struct SavedData: Codable {
        let records: [ActivityRecord]
        let duration: LearningDuration
        let goalStartedAt: Date
        let resetAt: Date
        let learningTopic: String?
    }

    // Load saved data or create mock records
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

        records.first { record in
            calendar.isDate(
                record.date,
                inSameDayAs: date
            )
            && record.timestamp >= resetAt
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

    // Create sample activity records
    private func addMockData() {

        let now = Date()

        guard let week = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) else {
            return
        }

        // Tuesday and Wednesday Learned
        // Thursday Frozen
        let mockDays: [(Int, ActivityStatus)] = [
            (3, .learned),
            (4, .learned),
            (5, .frozen)
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

    // Learned is available unless today is already Learned
    func canLog(at now: Date) -> Bool {
        status(on: now) != .learned
        && goalResult(at: now) == nil
    }

    // Freeze is available unless today is already Frozen
    func canFreeze(at now: Date) -> Bool {
        status(on: now) != .frozen
        && remainingFreezes(at: now) > 0
        && goalResult(at: now) == nil
    }

    // Register Learned or switch from Freeze to Learned
    func logLearned(at now: Date = Date()) {

        guard canLog(at: now) else {
            return
        }

        let today = startOfDay(now)

        // Remove previous record for today
        records.removeAll { record in
            calendar.isDate(
                record.date,
                inSameDayAs: today
            )
            && record.timestamp >= resetAt
        }

        // Register Learned
        records.append(
            ActivityRecord(
                date: today,
                timestamp: now,
                status: .learned
            )
        )

        save()
    }

    // Register Freeze or switch from Learned to Freeze
    func logFreeze(at now: Date = Date()) {

        guard canFreeze(at: now) else {
            return
        }

        let today = startOfDay(now)

        // Remove previous record for today
        records.removeAll { record in
            calendar.isDate(
                record.date,
                inSameDayAs: today
            )
            && record.timestamp >= resetAt
        }

        // Register Freeze
        records.append(
            ActivityRecord(
                date: today,
                timestamp: now,
                status: .frozen
            )
        )

        save()
    }

    // Calculate deadline after a recorded day
    private func deadline(after date: Date) -> Date? {

        guard let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay(date)
        ) else {
            return nil
        }

        // 32 hours from the beginning of the next day
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

    // Get the calendar period for the current goal
    private func goalPeriod() -> DateInterval? {
        period(containing: goalStartedAt)
    }

    // Count learned days within the goal period
    func goalLearnedDays() -> Int {

        guard let interval = goalPeriod() else {
            return 0
        }

        let learnedDates = records
            .filter { record in
                record.status == .learned
                && record.date >= interval.start
                && record.date < interval.end
                && record.timestamp >= resetAt
                && record.timestamp < interval.end
            }
            .map { startOfDay($0.date) }

        return Set(learnedDates).count
    }

    // Calculate total days in the goal period
    func goalTotalDays() -> Int {

        guard let interval = goalPeriod() else {
            return 0
        }

        return calendar.dateComponents(
            [.day],
            from: interval.start,
            to: interval.end
        ).day ?? 0
    }

    // Evaluate the goal only after the period ends
    func goalResult(at now: Date = Date()) -> GoalResult? {

        guard let interval = goalPeriod() else {
            return nil
        }

        // Do not show a result before the period ends
        guard now >= interval.end else {
            return nil
        }

        let totalDays = goalTotalDays()

        guard totalDays > 0 else {
            return nil
        }

        let learnedDays = goalLearnedDays()

        // More than 50% means Goal Completed
        if learnedDays > totalDays / 2 {
            return .completed
        }

        // Otherwise Goal Not Met
        return .notMet
    }

    // Set the initial learning goal
    func setInitialGoal(_ goal: LearningGoal) {

        let cleanedTopic = goal.topic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTopic.isEmpty else {
            return
        }

        learningTopic = cleanedTopic
        duration = goal.duration
        goalStartedAt = goal.startDate
        resetAt = goal.startDate

        // Start with fresh activity records
        records.removeAll()

        save()
    }

    // Update the learning goal
    @discardableResult
    func updateGoal(
        topic newTopic: String,
        duration newDuration: LearningDuration,
        at now: Date = Date()
    ) -> Bool {

        let cleanedTopic = newTopic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTopic.isEmpty else {
            return false
        }

        let topicChanged = cleanedTopic != learningTopic
        let durationChanged = newDuration != duration

        guard topicChanged || durationChanged else {
            return false
        }

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

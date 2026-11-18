//
//  ActivityViewModel.swift
//  LearningApp
//
//  Created by Reham Aljulayfi on 10/11/2026.
//


import Foundation
import Observation

// Possible activity statuses.
enum ActivityStatus: String, Codable {
    case learned
    case frozen
}

// Record for each logged day.
struct ActivityRecord: Codable {
    let date: Date
    let timestamp: Date
    let status: ActivityStatus
}

// Stores a completed goal with its activity records.
struct CompletedGoal: Codable, Identifiable {
    let goal: LearningGoal
    let records: [ActivityRecord]

    var id: UUID {
        goal.id
    }
}

@MainActor
@Observable
final class ActivityViewModel {

    // Shared ViewModel across pages.
    static let shared = ActivityViewModel()

    // Records belonging to the current goal only.
    var records: [ActivityRecord] = []

    // History of completed learning goals.
    private(set) var completedGoals: [CompletedGoal] = []

    // Current learning goal.
    private(set) var learningTopic = "Swift"
    private(set) var duration: LearningDuration = .week

    // Check whether a learning goal exists.
    private(set) var hasLearningGoal = false

    // Current goal dates.
    private(set) var goalStartedAt = Date()
    private(set) var resetAt = Date.distantPast

    // Calendar and storage.
    private let calendar = Calendar.current
    private let storageKey = "learning.activity.v3"

    // Protect existing data when loading fails.
    private(set) var hasStorageError = false
    private var canSaveData = true

    // Saved data structure.
    private struct SavedData: Codable {
        let records: [ActivityRecord]
        let duration: LearningDuration
        let goalStartedAt: Date
        let resetAt: Date
        let learningTopic: String?
        let hasLearningGoal: Bool?

        // Optional for compatibility with older saved data.
        let completedGoals: [CompletedGoal]?
    }

    // Load saved progress when the app starts.
    init() {
        let loadedSuccessfully = load()

        if !loadedSuccessfully {
            canSaveData = false
            hasStorageError = true
        }
    }

    // Get the beginning of a day.
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Check whether a record belongs to the current goal.
    private func isCurrentRecord(
        _ record: ActivityRecord
    ) -> Bool {
        record.timestamp >= resetAt
    }

    // Get the current goal's records.
    private var currentRecords: [ActivityRecord] {
        records.filter { isCurrentRecord($0) }
    }

    // Get the current goal status for a date.
    private func currentStatus(
        on date: Date
    ) -> ActivityStatus? {
        currentRecords.first { record in
            calendar.isDate(
                record.date,
                inSameDayAs: date
            )
        }?.status
    }

    // Get a date's status for the calendar.
    // Current records have priority over historical records.
    func status(on date: Date) -> ActivityStatus? {

        if let status = currentStatus(on: date) {
            return status
        }

        // Do not show historical records on or after
        // the current goal's starting day.
        guard date < startOfDay(goalStartedAt) else {
            return nil
        }

        // Search completed goals without changing them.
        for completedGoal in completedGoals.reversed() {

            if let record = completedGoal.records.first(
                where: {
                    calendar.isDate(
                        $0.date,
                        inSameDayAs: date
                    )
                }
            ) {
                return record.status
            }
        }

        return nil
    }

    // Get all dates in the current week.
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

    // Get the allowance period for a date.
    private func period(
        containing date: Date
    ) -> DateInterval? {

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

    // Calculate used Freeze Days for the current goal.
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

        return currentRecords.filter { record in
            record.status == .frozen
            && record.date >= periodStart
            && record.date < currentPeriod.end
        }.count
    }

    // Calculate remaining Freeze Days.
    func remainingFreezes(at now: Date) -> Int {
        max(
            0,
            duration.freezeLimit - usedFreezes(at: now)
        )
    }

    // Learned is available unless today is already Learned.
    func canLog(at now: Date) -> Bool {
        !hasStorageError
        && hasLearningGoal
        && now >= goalStartedAt
        && currentStatus(on: now) != .learned
        && goalResult(at: now) == nil
    }

    // Freeze is available unless today is already Frozen.
    func canFreeze(at now: Date) -> Bool {
        !hasStorageError
        && hasLearningGoal
        && now >= goalStartedAt
        && currentStatus(on: now) != .frozen
        && remainingFreezes(at: now) > 0
        && goalResult(at: now) == nil
    }

    // Register Learned or switch from Freeze to Learned.
    func logLearned(at now: Date = Date()) {

        guard canLog(at: now) else {
            return
        }

        let today = startOfDay(now)

        // Remove the current goal's record for today.
        records.removeAll { record in
            calendar.isDate(
                record.date,
                inSameDayAs: today
            )
            && isCurrentRecord(record)
        }

        // Register Learned.
        records.append(
            ActivityRecord(
                date: today,
                timestamp: now,
                status: .learned
            )
        )

        save()
    }

    // Register Freeze or switch from Learned to Freeze.
    func logFreeze(at now: Date = Date()) {

        guard canFreeze(at: now) else {
            return
        }

        let today = startOfDay(now)

        // Remove the current goal's record for today.
        records.removeAll { record in
            calendar.isDate(
                record.date,
                inSameDayAs: today
            )
            && isCurrentRecord(record)
        }

        // Register Freeze.
        records.append(
            ActivityRecord(
                date: today,
                timestamp: now,
                status: .frozen
            )
        )

        save()
    }

    // Calculate the deadline after a recorded day.
    private func deadline(after date: Date) -> Date? {

        guard let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay(date)
        ) else {
            return nil
        }

        // 32 hours from the beginning of the next day.
        return nextDay.addingTimeInterval(
            32 * 60 * 60
        )
    }

    // Calculate the current goal's Streak.
    func streak(at now: Date) -> Int {

        let sortedRecords = currentRecords
            .filter { record in
                record.timestamp <= now
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

    // Get the calendar period for the current goal.
    private func goalPeriod() -> DateInterval? {
        period(containing: goalStartedAt)
    }

    // Count Learned days for the current goal only.
    func goalLearnedDays() -> Int {

        guard let interval = goalPeriod() else {
            return 0
        }

        let learnedDates = currentRecords
            .filter { record in
                record.status == .learned
                && record.date >= interval.start
                && record.date < interval.end
                && record.timestamp < interval.end
            }
            .map { startOfDay($0.date) }

        return Set(learnedDates).count
    }

    // Calculate total days in the goal period.
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

    // Evaluate the goal after its period ends.
    func goalResult(
        at now: Date = Date()
    ) -> GoalResult? {

        guard hasLearningGoal,
              let interval = goalPeriod() else {
            return nil
        }

        // Do not show results before the period ends.
        guard now >= interval.end else {
            return nil
        }

        let totalDays = goalTotalDays()

        guard totalDays > 0 else {
            return nil
        }

        let learnedDays = goalLearnedDays()

        // More than 50% means Goal Completed.
        if learnedDays > totalDays / 2 {
            return .completed
        }

        return .notMet
    }

    // Set the initial learning goal.
    func setInitialGoal(_ goal: LearningGoal) {

        guard !hasStorageError,
              !hasLearningGoal else {
            return
        }

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

        // Clear records only for the first goal.
        records.removeAll()

        hasLearningGoal = true

        save()
    }

    // Update the current goal.
    // Completed goals are preserved in history.
    // All records of an unfinished goal are discarded.
    @discardableResult
    func updateGoal(
        topic newTopic: String,
        duration newDuration: LearningDuration,
        at now: Date = Date()
    ) -> Bool {

        guard !hasStorageError,
              hasLearningGoal else {
            return false
        }

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

        // Preserve the old goal only if it was completed.
        if goalResult(at: now) == .completed {

            let completedGoal = LearningGoal(
                topic: learningTopic,
                duration: duration,
                startDate: goalStartedAt,
                endDate: now
            )

            completedGoals.append(
                CompletedGoal(
                    goal: completedGoal,
                    records: currentRecords
                )
            )
        }

        // Remove every record belonging to the old
        // current goal, including previous days.
        records.removeAll()

        // Apply the updated goal.
        learningTopic = cleanedTopic
        duration = newDuration

        // Restart the current goal from today.
        goalStartedAt = now
        resetAt = now

        // Streak and Freeze usage now start at zero.
        save()

        return true
    }

    // Save activity data and completed goals.
    private func save() {

        guard canSaveData && !hasStorageError else {
            print("Saving blocked to protect existing data.")
            return
        }

        let savedData = SavedData(
            records: records,
            duration: duration,
            goalStartedAt: goalStartedAt,
            resetAt: resetAt,
            learningTopic: learningTopic,
            hasLearningGoal: hasLearningGoal,
            completedGoals: completedGoals
        )

        guard let encodedData = try? JSONEncoder().encode(
            savedData
        ) else {
            print("Failed to encode activity data.")
            return
        }

        UserDefaults.standard.set(
            encodedData,
            forKey: storageKey
        )
    }

    // Load saved activity data.
    @discardableResult
    private func load() -> Bool {

        // First launch: no saved data exists.
        guard let storedData = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return true
        }

        // Decode existing saved data.
        guard let decodedData = try? JSONDecoder().decode(
            SavedData.self,
            from: storedData
        ) else {
            print("Failed to decode saved activity data.")
            return false
        }

        // Restore the current learning goal.
        hasLearningGoal = decodedData.hasLearningGoal ?? true

        records = decodedData.records
        duration = decodedData.duration
        goalStartedAt = decodedData.goalStartedAt
        resetAt = decodedData.resetAt
        learningTopic = decodedData.learningTopic ?? "Swift"

        // Older saved data may not have goal history.
        completedGoals = decodedData.completedGoals ?? []

        return true
    }
}


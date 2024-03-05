import Foundation
import CasePaths

@CasePathable
@dynamicMemberLookup
public enum EarlyReminder: Equatable, Codable, Hashable {
    case none
    case predefined(ReminderTrigger)
    case custom
}

public extension EarlyReminder {
    static let choices: [EarlyReminder] =
        [
            .none,
            .predefined(ReminderTrigger(time: 5, unit: .minute)),
            .predefined(ReminderTrigger(time: 10, unit: .minute)),
            .predefined(ReminderTrigger(time: 15, unit: .minute)),
            .predefined(ReminderTrigger(time: 1, unit: .hour)),
            .predefined(ReminderTrigger(time: 2, unit: .hour)),
            .predefined(ReminderTrigger(time: 1, unit: .day)),
            .predefined(ReminderTrigger(time: 2, unit: .day)),
            .predefined(ReminderTrigger(time: 1, unit: .week)),
            .predefined(ReminderTrigger(time: 2, unit: .week)),
            .custom
        ]
}

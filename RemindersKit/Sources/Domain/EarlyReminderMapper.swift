import Foundation

public enum EarlyReminderMapper {
    public static func earlyReminderType(from trigger: ReminderTrigger?) -> EarlyReminder {
        guard let trigger else {
            return .none
        }
        let predefined: EarlyReminder = .predefined(trigger)

        if EarlyReminder.choices.contains(predefined) {
            return predefined
        } else {
            return .custom
        }
    }
}

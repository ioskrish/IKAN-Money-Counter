//
//  Constants.swift
//  iKAN
//
//  Created by Krishna Panchal on 26/11/23.
//

import UIKit
// swiftlint:disable identifier_name
let UD: UserDefaults = UserDefaults.standard
let NC = NotificationCenter.default
// swiftlint:enable identifier_name
let calendar = Calendar.current

var startDate: Date!
var endDate: Date!

struct Const {

    struct IDIB {
        static let tutorialVC = "TutorialController"
        static let settingsVC = "SettingsController"
        static let sliderVC = "SliderController"
        static let IKANVC = "IKANController"
    }

    struct UDef {
        static let hrlyRate = "hourlyRate"
        static let startTime = "startTime"
        static let endTime = "endTime"
        static let userSawTutorial = "userSawTutorial"
        static let weekdaysIWorkOn = "weekdaysIWorkOn"
    }

    struct UIMsg {
        static let timeToWorkEnd = "Workday ends in:"
        static let timeToWorkStart = "Workday starts in:"
        static let dailyMakeableRemaining = "How Much More You Can Make Today"
        static let dailyOutsideWorkingHours = "How Much You Can Make Daily"
        static let appName = "IKAN - Money Counter"
        static let tutorial = "Tutorial"
//        static let weekdaysNamesArr = ["S", "M", "T", "W", "T", "F", "S"]
        static let aWeekdayAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(for: .body, weight: .bold)
        ]
    }
}


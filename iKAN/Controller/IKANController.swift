//
//  IKANController.swift
//  iKAN
//
//  Created by Krishna Panchal on 26/11/23.
//

import UIKit
import MessageUI

@available(iOS 14.0, *)
class IKANController: UIViewController, SettingsPresenter, DeclaresVisibility {
    
    // MARK: Outlets

    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var howMuchDailyLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var workTimeLbl: UILabel!
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    

    // MARK: Properties

    // swiftlint:disable identifier_name
    var is😎Visible: Bool = false
    // swiftlint:enable identifier_name

    var timer = Timer()
    let numberFormatterCurrency = NumberFormatter()
    let myDateCompForm = DateComponentsFormatter()
    var hourlyRate: Double!

    enum WorkHoursStatus {
        case before
        case during
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

//        if CommandLine.arguments.contains("--iKAN") {
//            // We are in testing mode, make arrangements if needed
//            UIView.setAnimationsEnabled(false)
//        }
        
        aboutBtn.layer.cornerRadius = 7
        settingsBtn.layer.cornerRadius = 7

        timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self,
            selector: #selector(self.tick), userInfo: nil, repeats: true)

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterCurrency.roundingMode = .down

        for label: UILabel in [howMuchDailyLbl, workTimeLbl,
                               moneyLbl, timeLbl] {
            label.text = " "
        }

        fetchWorkHours()
        fetchHourlyRate()

        NC.addObserver(self, selector: #selector(fetchWorkHours),
                       name: .hrsDidChange, object: nil)
        NC.addObserver(self, selector: #selector(fetchHourlyRate),
                       name: .hrlyRateDidChange, object: nil)

        setThemeColorTo(myThemeColor: .white)

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        is😎Visible = true

        if !UD.bool(forKey: Const.UDef.userSawTutorial) {
            showHelp()
            UD.set(true, forKey: Const.UDef.userSawTutorial)
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        is😎Visible = false
    }


    // MARK: Helpers

    func showHelp() {

        let tutorialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: Const.IDIB.tutorialVC) as! TutorialController

        tutorialVC.delegate = self

        present(tutorialVC, animated: true)
    }


    @objc func fetchHourlyRate() {
        hourlyRate = UD.double(forKey: Const.UDef.hrlyRate)
    }


    @objc func fetchWorkHours() {
        guard let startTimeString: String = UD.string(forKey: Const.UDef.startTime) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeString",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeString: String = UD.string(forKey: Const.UDef.endTime) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeString",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        let startTimeH = startTimeString.prefix(2)
        let startTimeM = startTimeString.suffix(2)
        let endTimeH = endTimeString.prefix(2)
        let endTimeM = endTimeString.suffix(2)

        guard let startTimeHourInt: Int = Int(startTimeH) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeHourInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let startTimeMinInt: Int = Int(startTimeM) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeMinInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeHourInt: Int = Int(endTimeH) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeHourInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeMinInt: Int = Int(endTimeM) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeMinInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let nextWorkingDate = calendar.date(byAdding: .day,
                                                  value: daysToNextWorkWeekday(),
                                                  to: getNow()) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let nextWorkingDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let safeStartDate = calendar.date(bySettingHour: startTimeHourInt,
                                                minute: startTimeMinInt, second: 0,
                                                of: nextWorkingDate) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let safeStartDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let safeEndDate = calendar.date(bySettingHour: endTimeHourInt,
                                              minute: endTimeMinInt, second: 0,
                                              of: nextWorkingDate) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let safeEndDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        startDate = safeStartDate
        endDate = safeEndDate
    }


    func getWorkHoursStatus() -> WorkHoursStatus {

        let now = getNow()

        guard startDate < endDate else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "startTime < endTime",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return .before
        }

        if (startDate...endDate).contains(now) {
            return .during
        } else if now < startDate {
            return .before
        } else if now > endDate {
            return .before
        } else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(alert: alert, condition: "else",
                     someFunc: #function, someLine: #line)
            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
        }
        return .before
    }


    @objc func tick() {
        fetchWorkHours() // needed? causes issues?
        switch getWorkHoursStatus() {
            case .before:
                updateLabelsIfNextDayIsWorkday()
            case .during:
                updateLabelsDuringWorkHours()
        }
    }


    func updateLabelsDuringWorkHours() {
        workTimeLbl.text = Const.UIMsg.timeToWorkEnd
        howMuchDailyLbl.text = Const.UIMsg.dailyMakeableRemaining
        let now = getNow()

        let secsDiff = endDate.timeIntervalSince1970 - now.timeIntervalSince1970
        updateMoneyMakeableLabel(seconds: secsDiff)

        timeLbl.text = formTimerFrom(Int(secsDiff))
    }


    func updateLabelsIfNextDayIsWorkday() {
        workTimeLbl.text = Const.UIMsg.timeToWorkStart
        howMuchDailyLbl.text = Const.UIMsg.dailyOutsideWorkingHours

        let secsInFullWorkday = endDate
            .timeIntervalSince1970 - startDate.timeIntervalSince1970

        guard secsInFullWorkday > 0 else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "secsInFullWorkday > 0",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        updateMoneyMakeableLabel(seconds: secsInFullWorkday)

        var secsTillWorkdayBegins = 0.0

        let now = getNow()

        guard now < startDate || now >= endDate else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "now < startTime || now >= endTime",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        secsTillWorkdayBegins = startDate.timeIntervalSince1970 -
        now.timeIntervalSince1970

        guard secsTillWorkdayBegins >= 0 else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "secsTillWorkdayBegins >= 0",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        timeLbl.text = formTimerFrom(Int(secsTillWorkdayBegins))
    }


    func updateMoneyMakeableLabel(seconds: Double?) {

        guard let safeSeconds = seconds else {
            moneyLbl.text = " "
            return
        }

        let moneyLeft: Double = hourlyRate * safeSeconds / 3600.0
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyLbl.text = "\(moneyLeftFormatted!)"
    }


    func appendTo(alert: UIAlertController, condition: String,
                  someFunc: String, someLine: Int) {
        alert.message?.append("\n\n\n\n\(someFunc), \(someLine)")
        alert.message?.append("\n\(condition)")
        alert.message?.append("\nstart: \(startDate!)")
        alert.message?.append("\nend: \(endDate!)")
        alert.message?.append("\nnow: \(getNow())")
        alert.message?.append("\ndaysToNextWorkWeekday: \(daysToNextWorkWeekday())")
    }


    func formTimerFrom(_ seconds: Int) -> String {

        myDateCompForm.allowedUnits = [.day, .hour, .minute, .second]
        myDateCompForm.unitsStyle = .abbreviated
        myDateCompForm.zeroFormattingBehavior = [.dropAll]

        guard let mySafeString = myDateCompForm.string(
            from: DateComponents(second: seconds)) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "let mySafeString = myDateCompForm.string",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return "error getting time"
        }
        return mySafeString
    }


    @IBAction func settingsTapped() {
        presentSettings()
    }
    
    @IBAction func aboutTapped(_ sender: UIButton) {
        self.showHelp()
    }

    func presentSettings() {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Const.IDIB.settingsVC)
        as! SettingsController
        is😎Visible = false
        settingsVC.delegate = self
        present(settingsVC, animated: true)
    }


    func invalTimerAndSetHelperLabel() {
        self.timer.invalidate()
        timeLbl.text = ""
        howMuchDailyLbl.text = " "
        workTimeLbl.font = UIFont(name: "AvenirNext-Medium", size: 16)
        workTimeLbl.text = "Error: Adjust in-app Settings and restart app"
    }
}


protocol SettingsPresenter {
    func presentSettings()
}


protocol DeclaresVisibility {
    // swiftlint:disable identifier_name
    var is😎Visible: Bool { get set }
    // swiftlint:enable identifier_name
}


// Helper function inserted by Swift 4.2 migrator.

private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in
            (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }

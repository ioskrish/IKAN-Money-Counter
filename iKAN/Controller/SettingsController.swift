//
//  SettingsController.swift
//  iKAN
//
//  Created by Krishna Panchal on 26/11/23.
//

import UIKit

@available(iOS 14.0, *)
class SettingsController: UIViewController, UITextFieldDelegate,
                          UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    // MARK: Properties
    
    var delegate: DeclaresVisibility?
    
    let sTimeCell = "TimerCell"
    let sHourlyCell = "HourlyCell"
    let sWeekdayCell = "WeekdayCell"
    
    let myDataSourceLabels = [
        [
            "Work start time:",
            "Work end time:"
        ],
        [
            "Hourly rate:"
        ]
    ]
    
    let myDataSourceTitles = [
        "Enter what times you start and end work",
        "Enter how much you get paid per hour",
        "Select what weekdays you work on"
    ]
    
    let numberFormatterCurrency = NumberFormatter()
    let numberFormatterReset = NumberFormatter()
    let dateFormatterHM = DateFormatter()
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    if CommandLine.arguments.contains("--iKAN") {
        //        // We are in testing mode, make arrangements if needed
        //        UIView.setAnimationsEnabled(false)
        //    }
        
        doneBtn.layer.cornerRadius = 7
        
        numberFormatterCurrency.numberStyle = .currency
        numberFormatterReset.numberStyle = .none
        dateFormatterHM.dateFormat = "HH:mm"
        
        self.title = "Settings"
        
    }
    
    // MARK: Helpers
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.is😎Visible = true
        }
    }
    
    
    @objc func fetchWorkHours(aDatePicker: UIDatePicker) {
        let startTimeString: String = UD.string(forKey: Const.UDef.startTime)!
        let endTimeString: String = UD.string(forKey: Const.UDef.endTime)!
        
        let startTimeH = startTimeString.prefix(2)
        let startTimeM = startTimeString.suffix(2)
        let endTimeH = endTimeString.prefix(2)
        let endTimeM = endTimeString.suffix(2)
        let startTimeHourInt: Int = Int(startTimeH)!
        let startTimeMinInt: Int = Int(startTimeM)!
        let endTimeHourInt: Int = Int(endTimeH)!
        let endTimeMinInt: Int = Int(endTimeM)!
        
        let now = getNow()
        
        if aDatePicker.tag == 0 {
            aDatePicker.date = calendar.date(
                bySettingHour: startTimeHourInt,
                minute: startTimeMinInt, second: 0, of: now)!
        } else {
            aDatePicker.date = calendar.date(
                bySettingHour: endTimeHourInt,
                minute: endTimeMinInt, second: 0, of: now)!
        }
        
    }
    
    
    func addAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let textFieldSaveButton = UIBarButtonItem(
            title: "Save",
            style: .done, target: self,
            action: #selector(self.textFieldSaveTapped))
        let spacer = UIBarButtonItem.flexibleSpace()
        toolBar.items = [spacer, textFieldSaveButton]
        return toolBar
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldSaveTapped()
        return true
    }
    
    
    @objc func textFieldSaveTapped() {
        
        let aTextField: UITextField = (settingTableView.cellForRow(
            at: IndexPath(row: 0, section: 1)) as! HourlyCell
        ).hourTxtField
        
        aTextField.resignFirstResponder()
        
        guard let userInput: String = aTextField.text else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }
        
        let droppedCurrencySymbol: String = userInput.replacingOccurrences(
            of: numberFormatterCurrency.currencySymbol, with: "")
        guard let rateAsDouble = Double(droppedCurrencySymbol) else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }
        
        guard let rateAsCurrency: String = numberFormatterCurrency.string(
            from: rateAsDouble as NSNumber) else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }
        
        UD.set(rateAsDouble, forKey: Const.UDef.hrlyRate)
        NC.post(name: .hrlyRateDidChange, object: nil)
        
        aTextField.text = rateAsCurrency
        
    }
    
    
    func restoreOldRateCuzNewFailed(textField: UITextField) {
        let oldHourlyRate = UD.double(forKey: Const.UDef.hrlyRate)
        textField.text = numberFormatterCurrency.string(from: oldHourlyRate as NSNumber)
    }
    
    
    @objc func workScheduleChanged(sender: UIDatePicker) {
        // Start time tag: 0
        // End time tag: 1
        let time = sender.date
        let formatted = dateFormatterHM.string(from: time)
        
        switch sender.tag {
        case 0:
            UD.set(formatted, forKey: Const.UDef.startTime)
        case 1:
            UD.set(formatted, forKey: Const.UDef.endTime)
        default:
            fatalError()
        }
        NC.post(name: .hrsDidChange, object: nil)
    }
    
    
    @objc func weekdaysChanged(sender: UIButton) {
        var oldWeekdays = getWeekdaysArrBool()
        oldWeekdays[sender.tag].toggle()
        UD.set(oldWeekdays, forKey: Const.UDef.weekdaysIWorkOn)
        settingTableView.reloadSections(IndexSet(integer: 2), with: .none)
        NC.post(name: .hrsDidChange, object: nil)
    }
    
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // work start/end times, hourly rate, weekdays
    }
    
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            return myDataSourceTitles[section]
        }
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2 // start time, end time
        case 1:
            return 1 // hourly rate
        case 2: // weekdays
            return 1
        default:
            fatalError()
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TimerCell") as! TimerCell
                cell.timeLbl.text =
                myDataSourceLabels[indexPath.section][indexPath.row]
                cell.timerPicker.tag = indexPath.row
                fetchWorkHours(aDatePicker: cell.timerPicker)
                cell.timerPicker.addTarget(
                    self,
                    action: #selector(workScheduleChanged(sender:)), for: .valueChanged)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TimerCell") as! TimerCell
                cell.timeLbl.text =
                myDataSourceLabels[indexPath.section][indexPath.row]
                cell.timerPicker.tag = indexPath.row
                fetchWorkHours(aDatePicker: cell.timerPicker)
                cell.timerPicker.addTarget(
                    self,
                    action: #selector(workScheduleChanged(sender:)), for: .valueChanged)
                return cell
            default:
                fatalError()
            }
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "HourlyCell") as! HourlyCell
            cell.hourLbl.text = myDataSourceLabels[indexPath.section][indexPath.row]
            cell.hourTxtField.inputAccessoryView = addAccessoryView()
            let hourlyRate = UD.double(forKey: Const.UDef.hrlyRate)
            cell.hourTxtField.text = numberFormatterCurrency.string(
                from: hourlyRate as NSNumber)
            cell.hourTxtField.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell")
            as! WeekdayCell
            
            let weekdaysArr = getWeekdaysArrBool()
            
            let weekdaysShortNamesArr: [String] = DateFormatter()
                .veryShortStandaloneWeekdaySymbols
            
            for (myIndex, button) in [cell.sundayBtn,
                                      cell.mondayBtn,
                                      cell.tuesdayBtn,
                                      cell.wednesdayBtn,
                                      cell.thursdayBtn,
                                      cell.fridayBtn,
                                      cell.saturdayBtn].enumerated() {
                button?.tag = myIndex
                let anAttrTitle = NSAttributedString(
                    string: weekdaysShortNamesArr[myIndex],
                    attributes: Const.UIMsg.aWeekdayAttr)
                button?.setAttributedTitle(anAttrTitle, for: .normal)
                
                button?.layer.cornerRadius = (button?.frame.width ?? 1)/2
                button?.backgroundColor = weekdaysArr[myIndex] ? #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
                : .clear
                button?.tintColor = weekdaysArr[myIndex] ? .white : .label
                button?.addTarget(self, action: #selector(weekdaysChanged),
                                  for: .touchUpInside)
                
            }
            return cell
        default:
            fatalError()
        }
    }
    
}

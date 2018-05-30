//
//  AddCourseworkViewController.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 04/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddCourseworkViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textCourseworkName: UITextField!
    @IBOutlet weak var textModuleName: UITextField!
    @IBOutlet weak var textFieldStartDate: UITextField!
    @IBOutlet weak var textFieldDeadline: UITextField!
    @IBOutlet weak var switchReminder: UISwitch!
    @IBOutlet weak var textLevel: UITextField!
    @IBOutlet weak var textNotes: UITextView!
    @IBOutlet weak var labelPlaceholder: UILabel!
    @IBOutlet weak var textMark: UITextField!
    @IBOutlet weak var textWeight: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    var currentCoursework:Coursework?
    var list =  ["Level 4", "Level 5", "Level 6", "Level 7"]
    var selectedLevel:String?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isCourseworkNameAnInteger: Bool = false
    var isModuleNameAnInteger: Bool = false
    var isMarkAnInteger: Bool = false
    var isWeightAnInteger: Bool = false
    var isNotesAnInteger: Bool = false
    var isEdit:Bool = false
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEdit {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            textModuleName.text = currentCoursework?.moduleName
            textCourseworkName.text = currentCoursework?.name
            textMark.text = "\(currentCoursework?.mark ?? 0)"
            textWeight.text = "\(currentCoursework?.weight ?? 0)"
            textLevel.text = currentCoursework?.level
            startDatePicker.date = (currentCoursework?.startDate)!
            endDatePicker.date = (currentCoursework?.dueDate)!
            textFieldStartDate.text = dateFormatter.string(from: startDatePicker.date)
            textFieldDeadline.text = dateFormatter.string(from: endDatePicker.date)
            textNotes.text = currentCoursework?.notes
            switchReminder.isOn = (currentCoursework?.isReminderSet)!
        }
        
        createLevelPicker()
        createToolbarForLevelPicker()
        createDatePicker()
        addNotesPlaceholderAndBorder()
    }
    
    func addNotesPlaceholderAndBorder() {
        textNotes.layer.borderWidth = 0.5
        textNotes.layer.borderColor = UIColor.black.cgColor
        
        textNotes.delegate = self
        labelPlaceholder.text = "Notes"
        labelPlaceholder.sizeToFit()
        textNotes.addSubview(labelPlaceholder)
        labelPlaceholder.frame.origin = CGPoint(x: 5, y: (textNotes.font?.pointSize)! / 2)
        labelPlaceholder.textColor = UIColor.lightGray
        labelPlaceholder.isHidden = !textNotes.text.isEmpty
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        labelPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func createLevelPicker() {
        let levelPicker = UIPickerView()
        levelPicker.delegate = self
        textLevel.inputView = levelPicker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createDatePicker() {
        
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        textFieldStartDate.inputAccessoryView = toolbar
        textFieldStartDate.inputView = startDatePicker
        textFieldDeadline.inputAccessoryView = toolbar
        textFieldDeadline.inputView = endDatePicker
    }
    
    func createToolbarForLevelPicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddCourseworkViewController.dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        textLevel.inputAccessoryView = toolbar
    }
    
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func donePressed () {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
    
        endDatePicker.minimumDate = startDatePicker.date
        textFieldStartDate.text = dateFormatter.string(from: startDatePicker.date)
        textFieldDeadline.text = dateFormatter.string(from: endDatePicker.date)
        self.view.endEditing(true)
    }
    
    
    @IBAction func saveCoursework(_ sender: Any) {
        
        let dueDateStartDay = Calendar.current.date(bySettingHour: 12, minute: 00, second: 0, of: endDatePicker.date)!
        
        isCourseworkNameAnInteger = isStringAnInt(string: textCourseworkName.text!)
        isModuleNameAnInteger = isStringAnInt(string: textModuleName.text!)
        isMarkAnInteger = isStringAnInt(string: textMark.text!)
        isWeightAnInteger = isStringAnInt(string: textWeight.text!)
        isNotesAnInteger = isStringAnInt(string: textNotes.text!)
        
        let everythingIsCorrect = checkIfAllGood()
        
        if everythingIsCorrect {
            var newCoursework = Coursework()
            
            if isEdit {
                newCoursework = currentCoursework!
            }
            else {
                newCoursework = Coursework(context: context)
            }
            
            newCoursework.name = textCourseworkName.text
            newCoursework.moduleName = textModuleName.text
            newCoursework.mark = Int32(textMark.text!)!
            newCoursework.weight = Int32(textWeight.text!)!
            newCoursework.level = textLevel.text
            newCoursework.startDate = startDatePicker.date
            newCoursework.dueDate = dueDateStartDay
            newCoursework.notes = textNotes.text
            if !isEdit {
                newCoursework.completion = 0.0
            }
            newCoursework.isReminderSet = switchReminder.isOn
            
            if switchReminder.isOn {
                let eventStore:EKEventStore = EKEventStore()
                
                eventStore.requestAccess(to: .event, completion: {(granted, error) in
                    DispatchQueue.main.async {
                        
                        if(granted) && (error == nil) {
                            let event:EKEvent = EKEvent(eventStore: eventStore)
                            event.title = self.textCourseworkName.text
                            event.startDate = dueDateStartDay
                            event.endDate = dueDateStartDay
                            event.notes = self.textNotes.text
                            event.calendar = eventStore.defaultCalendarForNewEvents
                            let alarm:EKAlarm = EKAlarm(relativeOffset: -60)
                            event.alarms = [alarm]
                            do {
                                try eventStore.save(event, span: .thisEvent)
                            } catch let error as NSError{
                                print(error)
                            }
                        }
                    }
                })
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)
        }
            
        else if textModuleName.text == "" {
            createAlert(message: "Missing Module Name", description: "Please Enter a Module Name")
        }
        else if isModuleNameAnInteger {
            createAlert(message: "Valid Module name", description: "Please enter a valid Module name")
        }
            
        else if textCourseworkName.text == "" {
            createAlert(message: "Missing Coursework Name", description: "Please Enter a Coursework Name")
        }
            
        else if isCourseworkNameAnInteger {
            createAlert(message: "Valid Coursework name", description: "Please Enter a Valid Coursework Name")
        }
            
        else if !isMarkAnInteger {
            createAlert(message: "Valid mark", description: "Please Enter a Valid Predicted Mark, Desired Mark or Actual Mark")
        }
        else if Int(textMark.text!)! > 100 {
            createAlert(message: "Valid mark", description: "Mark Cannot be over 100")
        }
        else if !isWeightAnInteger {
            createAlert(message: "Valid weight", description: "Please Enter a Valid Weight")
        }
        else if Int(textWeight.text!)! > 100 {
            createAlert(message: "Valid weight", description: "Weight Cannot be over 100")
        }
        else if isNotesAnInteger {
            createAlert(message: "Valid notes", description: "Please Enter Valid Notes")
        }
        else if textLevel.text != "Level 4" && textLevel.text != "Level 5" && textLevel.text != "Level 6" && textLevel.text != "Level 7"{
            createAlert(message: "Valid Level", description: "Please Select a Valid Level")
        }
        else if textFieldDeadline.text == ""{
            createAlert(message: "Valid Date", description: "Please Select a Valid End Date")
        }
        else if textFieldStartDate.text == ""{
            createAlert(message: "Valid Date", description: "Please Select a Valid Start Date")
        }
        
        
    }
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    func checkIfAllGood() -> Bool {
        var allGood: Bool = false
        if textCourseworkName.text != "" && !isCourseworkNameAnInteger && textModuleName.text != "" && !isModuleNameAnInteger && isMarkAnInteger && Int(textMark.text!)! <= 100 && isWeightAnInteger && Int(textWeight.text!)! <= 100 && textLevel.text != "" && textFieldStartDate.text != "" && textFieldDeadline.text != "" {
            allGood = true
        }else {
            allGood = false
        }
        return allGood
    }
    
    func createAlert(message:String, description:String) {
        let alert = UIAlertController(title: message, message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension AddCourseworkViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLevel = list[row]
        textLevel.text  = selectedLevel
    }
}

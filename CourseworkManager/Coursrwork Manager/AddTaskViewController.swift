//
//  AddTaskViewController.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 04/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddTaskViewController: UIViewController {
    

    @IBOutlet weak var textTaskName: UITextField!
    @IBOutlet weak var textTaskDescription: UITextField!
    @IBOutlet weak var labelAddTask: UILabel!
    @IBOutlet weak var textPercentageCompleted: UITextField!
    @IBOutlet weak var sliderPercentage: UISlider!
    @IBOutlet weak var textStartDate: UITextField!
    @IBOutlet weak var textEndDate: UITextField!
    @IBOutlet weak var switchReminder: UISwitch!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentCoursework:Coursework?
    var currentTask:Task?
    var isEdit:Bool = false
    var isTaskNameAnInteger:Bool = false
    var isDescriptionAnInteger:Bool = false

    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        textTaskName.placeholder = "Task Name"
        textTaskDescription.placeholder = "Task Description"
        textStartDate.placeholder = "Start Date"
        textEndDate.placeholder = "End Date"

        
        if isEdit {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            textTaskName.text = currentTask?.name
            startDatePicker.date = (currentTask?.startDate)!
            endDatePicker.date = (currentTask?.endDate)!
            textStartDate.text = dateFormatter.string(from: startDatePicker.date)
            textEndDate.text = dateFormatter.string(from: endDatePicker.date)
            textTaskDescription.text = currentTask?.taskDescription
            textPercentageCompleted.text = "\(Int((currentTask?.percentageComplete)! * 100))%"
            sliderPercentage.value = (currentTask?.percentageComplete)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changePercentageLabel(_ sender: UISlider) {
        let wholeNumber = Int(round(sliderPercentage.value * 100))
        textPercentageCompleted.text = "\(wholeNumber)%"
    }
    
    @IBAction func SaveTask(_ sender: Any) {
        
        var task = Task()
        isTaskNameAnInteger = isStringAnInt(string: textTaskName.text!)
        let dueDateStartDay = Calendar.current.date(bySettingHour: 12, minute: 00, second: 0, of: endDatePicker.date)!
        let everythingIsCorrect = checkIfAllGood()

        if everythingIsCorrect {
        if isEdit {
            task = currentTask!
        }
        else {
        task = Task(context: self.context)
        }
            task.name = self.textTaskName.text
            task.taskDescription = self.textTaskDescription.text
            task.percentageComplete = (((self.textPercentageCompleted.text! as NSString).floatValue)/100)
            task.startDate = startDatePicker.date
            task.endDate = endDatePicker.date
            if switchReminder.isOn {
                let eventStore:EKEventStore = EKEventStore()
                
                eventStore.requestAccess(to: .event, completion: {(granted, error) in
                    DispatchQueue.main.async {
                        
                        if(granted) && (error == nil) {
                            let event:EKEvent = EKEvent(eventStore: eventStore)
                            event.title = self.textTaskName.text
                            event.startDate = dueDateStartDay
                            event.endDate = dueDateStartDay
                            event.notes = self.textTaskDescription.text
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
            self.currentCoursework?.addToCourseworkSubTasks(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        dismiss(animated: true, completion: nil)
    }
        else if textTaskName.text == "" {
            createAlert(message: "Valid Name", description: "Please Enter a Valid Task Name")
        }
        else if isTaskNameAnInteger {
            createAlert(message: "Valid Name", description: "Please Enter a Valid Task Name")
        }
        else if textStartDate.text == "" {
            createAlert(message: "Valid Date", description: "Please Select a Valid Start Date")
        }
        else if textEndDate.text == "" {
            createAlert(message: "Valid Date", description: "Please Select a Valid End Date")
        }
    }
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    func checkIfAllGood() -> Bool {
        var allGood: Bool = false

        if textTaskName.text != "" && textStartDate.text != "" && textEndDate.text != "" {
            allGood = true
        } else {
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

    func createDatePicker() {
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        textStartDate.inputAccessoryView = toolbar
        textStartDate.inputView = startDatePicker
        textEndDate.inputAccessoryView = toolbar
        textEndDate.inputView = endDatePicker
    }
    
    @objc func donePressed (){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        endDatePicker.minimumDate = startDatePicker.date
        textStartDate.text = dateFormatter.string(from: startDatePicker.date)
        textEndDate.text = dateFormatter.string(from: endDatePicker.date)

        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

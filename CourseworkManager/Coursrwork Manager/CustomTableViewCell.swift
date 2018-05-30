//
//  CustomTableViewCell.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 10/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import EventKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonCalculate: UIButton!
    @IBOutlet weak var textTitle: UITextField!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var dueDays: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    
    let percent = CAShapeLayer()
    var pulse = CAShapeLayer()
    var sliderValue: Float = 0.0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isEdit: Bool = false
    var currentTask:Task = Task()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Progress"
        label.textAlignment = .center
        label.font = UIFont.init(name: "DKJambo", size: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        return label
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        textTitle.isUserInteractionEnabled = false
        textTitle.borderStyle = UITextBorderStyle.none

    }
    
    func updateDaysLeftTextField(endDate: Date) {
        
        let calendar = NSCalendar.current
        let calendarDate1 = calendar.startOfDay(for: Date())
        let calendarDate2 = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: calendarDate1, to: calendarDate2)
        
        if components.day! > 0 {
            dueDays.text = "Due in \(components.day ?? 0) days"
        } else if components.day! == 0 {
            dueDays.text = "Deadline is today!"
        } else {
            dueDays.text = "Deadline has passed!"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
    func drawProgressBar(strokeEnd:Float){
        progressView.backgroundColor = UIColor.black
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 50, y: 15))
        line.addLine(to: CGPoint(x: 600, y: 15))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = line.cgPath
        shapeLayer.lineWidth = 200
        
        percent.path = line.cgPath
        percent.strokeColor = UIColor.init(red: 234/255, green: 46/255, blue: 111/255, alpha: 1).cgColor
        percent.lineWidth = 20
        percent.strokeEnd = 0
        
        pulse.path = line.cgPath
        pulse.strokeColor =  UIColor.init(red: 56/255, green: 25/255, blue: 49/255, alpha: 1).cgColor
        pulse.lineWidth = 20
        progressView.layer.addSublayer(pulse)
        progressView.layer.addSublayer(percent)
        progressView.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        percentageLabel.center = CGPoint(x: 125.0, y: 15.0)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        percentageLabel.text = "Completion: \(Int(round(strokeEnd * 100)))%"
    
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        DispatchQueue.main.async {
            self.percent.strokeEnd = CGFloat(strokeEnd)
            self.percent.add(basicAnimation, forKey: "qwertyu")
            
        }
    }
    
    func deleteCalendarEvent(startDate: Date, endDate: Date, courseName:String) {
        let eventStore:EKEventStore = EKEventStore()
        let dueDateStartDay = Calendar.current.date(bySettingHour: 12, minute: 00, second: 0, of: endDate)!
        
        let startDate = startDate.addingTimeInterval(60*60*24*(-2))
        let endDate = endDate.addingTimeInterval(60*60*24*7)
        
        let predicate2 = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: nil)
        
        let eV = eventStore.events(matching: predicate2) as [EKEvent]!
        
        if eV != nil {
            for i in eV! {
                
                do{
                    if i.title == courseName &&  i.startDate == dueDateStartDay {
                        (try eventStore.remove(i, span: EKSpan.thisEvent, commit: true))
                    }
                }
                catch let error {
                    print("Error", error)
                }
                
            }
        }
    }


}

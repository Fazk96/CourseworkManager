//
//  MasterTableViewCell.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 15/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import EventKit

class MasterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textCoursworkName: UILabel!
    @IBOutlet weak var textModuleName: UILabel!
    @IBOutlet weak var textDaysRemaining: UILabel!
    @IBOutlet weak var progressView: UIView!

    var courseworkName:String = ""
    var endDate:Date?
    let percent = CAShapeLayer()
    var pulse = CAShapeLayer()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
//        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.font = UIFont.init(name: "DKJambo", size: 16)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        return label
    }()
    
    
    func updateDaysRemaining(endDate: Date){
        let calendar = NSCalendar.current
        
        let calendarDate1 = calendar.startOfDay(for: Date())
        let calendarDate2 = calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([.day], from: calendarDate1, to: calendarDate2)
        
        if components.day != 0 {
            textDaysRemaining.text = "\(components.day ?? 0) days remaining"
        } else if components.day! == 0 {
            textDaysRemaining.text = "Deadline is today!"
        }
        else {
            textDaysRemaining.text = "Deadline has passed!"
        }
        
    }
    
    
    func drawProgressBar(strokeEnd:Float){
        progressView.backgroundColor = UIColor.clear
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 0, y: 15))
        line.addLine(to: CGPoint(x: 250, y: 15))
        
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
        pulse.borderWidth = 50
        pulse.borderColor = UIColor.blue.cgColor
        
        
        progressView.layer.addSublayer(pulse)
        progressView.layer.addSublayer(percent)
        progressView.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        percentageLabel.center = CGPoint(x: 70.0, y: 15.0)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        percentageLabel.text = "Completion: \(Int(round(strokeEnd * 100)))%"
        
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        DispatchQueue.main.async {
            self.percent.strokeEnd = CGFloat(strokeEnd)
            self.percent.add(basicAnimation, forKey: "fewfwef")
            
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
    func deleteCalendarEventEvent(startDate: Date, endDate: Date, courseName:String) {
        let eventStore:EKEventStore = EKEventStore()
        let dueDateStartDay = Calendar.current.date(bySettingHour: 12, minute: 00, second: 0, of: endDate)!
        
        let startDate = startDate.addingTimeInterval(60*60*24*(-2))
        let endDate = endDate.addingTimeInterval(60*60*24*7)
        
        let predicate2 = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: nil)

        let eV = eventStore.events(matching: predicate2) as [EKEvent]?
        
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

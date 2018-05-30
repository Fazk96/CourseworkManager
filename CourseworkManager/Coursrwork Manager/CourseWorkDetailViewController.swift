//
//  CourseWorkDetailViewController.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 04/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit

class CourseWorkDetailViewController: UIViewController {
    
    @IBOutlet weak var labelCourseworkName: UILabel!
    @IBOutlet weak var completionView: UIView!
    @IBOutlet weak var textMark: UILabel!
    @IBOutlet weak var textWeight: UILabel!
    @IBOutlet weak var textLevel: UILabel!
    @IBOutlet weak var textDueDate: UILabel!
    @IBOutlet weak var textNotes: UITextView!
    
    @IBOutlet weak var textStartDate: UILabel!
    @IBOutlet weak var viewDaysRemaining: UIView!
    @IBOutlet weak var labelDaysRemaining: UILabel!
    
    
    let completionTrack = CAShapeLayer()
    var pulse: CAShapeLayer!
    
    var courseworkName:String?
    var mark:Int32?
    var weight:Int32?
    var level:String?
    var completion:Float?
    var startDate:Date?
    var dueDate:Date?
    var notes:String?
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.init(name: "DKJambo", size: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        return label
    }()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if dueDate != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MMM-yyyy"
            let formattedDate = formatter.string(from: (dueDate! as Date))
            let formattedDate2 = formatter.string(from: (startDate! as Date))
            
            labelCourseworkName.text = courseworkName
            textMark.text = "\(mark ?? 0)%"
            textWeight.text = "\(weight ?? 0)%"
            textLevel.text = "\(level ?? "")"
            textStartDate.text = "\(formattedDate2)"
            textDueDate.text = "\(formattedDate)"
            textNotes.text = "\(notes ?? "")"
            animateDaysRemainingText()
        }
        
        self.view.addSubview(completionView)
        createCompletionAnimations(completion: 3.2)
        completionView.backgroundColor = UIColor.clear
        
    }
    
    func animateDaysRemainingText() {
        
        let calendar = NSCalendar.current
        let calendarDate1 = calendar.startOfDay(for: Date())
        let calendarDate2 = calendar.startOfDay(for: dueDate!)
        
        let components = calendar.dateComponents([.day], from: calendarDate1, to: calendarDate2)
        
        labelDaysRemaining.numberOfLines = 2
        
        if (components.day! > 0) {
            labelDaysRemaining.text = "\(components.day ?? 0) Days\nRemaining!"
        } else if components.day! == 0 {
            labelDaysRemaining.text = "Deadline is today!"
        }
        else {
            labelDaysRemaining.text = "Deadline has passed!"
        }
        
        if Double(self.completion!) < 0.6 {
            labelDaysRemaining.textColor = UIColor.red
        } else if Double(self.completion!) >= 0.6 &&  Double(self.completion!) < 0.8 {
            labelDaysRemaining.textColor = UIColor.init(red: 232/255, green: 138/255, blue: 14/255, alpha: 1) // orange
        } else {
            labelDaysRemaining.textColor = UIColor.init(red: 34/255, green: 168/255, blue: 7/255, alpha: 1) //green
        }
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        viewDaysRemaining.layer.add(pulseAnimation, forKey: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func createCompletionAnimations(completion: Float){
        
        let track = CAShapeLayer()
        let circle = UIBezierPath(arcCenter: .zero, radius: 70, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        pulse = CAShapeLayer()
        pulse.path = circle.cgPath
        pulse.strokeColor = UIColor.clear.cgColor
        pulse.lineWidth = 10
        pulse.fillColor = UIColor.init(red: 86/255, green: 30/255, blue: 63/255, alpha: 1.0).cgColor
        pulse.lineCap = kCALineCapRound
        pulse.position = CGPoint(x: 150.0, y: 110.0)
        
        completionView.layer.addSublayer(pulse)
        
        track.path = circle.cgPath
        track.strokeColor = UIColor.init(red: 56/255, green: 25/255, blue: 49/255, alpha: 1).cgColor
        track.lineWidth = 20
        track.fillColor = UIColor.black.cgColor
        track.lineCap = kCALineCapRound
        track.position = CGPoint(x: 150.0, y: 110.0)
        
        completionView.layer.addSublayer(track)
        
        animatePulse()
        
        completionTrack.path = circle.cgPath
        completionTrack.strokeColor = UIColor.init(red: 234/255, green: 46/255, blue: 111/255, alpha: 1).cgColor
        completionTrack.lineWidth = 20
        completionTrack.fillColor = UIColor.clear.cgColor
        completionTrack.lineCap = kCALineCapRound
        completionTrack.position = CGPoint(x: 150.0, y: 110.0)
        completionTrack.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        completionTrack.strokeEnd = 0
        
        completionView.layer.addSublayer(completionTrack)
        
        animate()
        
        completionView.addSubview(percentageLabel)
        
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = CGPoint(x: 150.0, y: 110.0)
            }

    
    func animatePulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulse.add(animation, forKey: "bahdbehwbfk")
    }
    
    @objc func animate() {

        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.duration = 1
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        
        DispatchQueue.main.async {

            let cgFloatPercentageCompleted:CGFloat = CGFloat(self.completion ?? 0.0)
            let percentageInt = Int(round(cgFloatPercentageCompleted * 100))
            self.percentageLabel.text = "\(percentageInt)% \n Completed "
            self.completionTrack.strokeEnd = cgFloatPercentageCompleted
            self.completionTrack.add(basicAnimation, forKey: "qwerty")
            
        }
    }
    
    
}

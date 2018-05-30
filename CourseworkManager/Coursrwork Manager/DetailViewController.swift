//
//  DetailViewController.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 04/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task] = []
    var numberOfTasks:Int = 0
    var isEdit: Bool = false
    var currentTask:Task?
    
    @IBOutlet weak var labelNoSelection: UILabel!
    @IBOutlet weak var courseDetailView: UIView!
    @IBOutlet weak var addTaskToolBar: UIToolbar!
    @IBOutlet weak var labelNoSelection2: UILabel!
    @IBOutlet weak var labelNoSelectionInstructions: UILabel!
    @IBOutlet weak var detailLabel: UINavigationItem!
    @IBOutlet weak var green: UILabel!
    @IBOutlet weak var orange: UILabel!
    @IBOutlet weak var red: UILabel!
    @IBOutlet weak var labelOver80: UILabel!
    @IBOutlet weak var labelOver60: UILabel!
    @IBOutlet weak var labelUnder60: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        detailLabel.title = coursework?.moduleName

        
        if coursework?.moduleName == nil {
            courseDetailView.isHidden = true
            addTaskToolBar.isHidden = true
        }
        else {
            labelNoSelection.isHidden = true
            labelNoSelection2.isHidden = true
            labelNoSelectionInstructions.isHidden = true
            green.isHidden = true
            orange.isHidden = true
            red.isHidden = true
            labelOver80.isHidden = true
            labelOver60.isHidden = true
            labelUnder60.isHidden = true




        }
        
    }
    
    
    func calculateTotalPercentageComplete()
    {
        var percentageComplete: Float = 0.0
        
        if tasks.count > 0 {
            for task in tasks{
                percentageComplete = percentageComplete + task.percentageComplete
            }
        }
        
        self.coursework?.completion = percentageComplete/Float(numberOfTasks)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10/10), execute: {
//            self.calculateTotalPercentageComplete()
//            if self.childViewControllers.count > 0 {
//                let viewControllers:[UIViewController] = self.childViewControllers
//                for viewContoller in viewControllers{
//                    viewContoller.willMove(toParentViewController: nil)
//                    viewContoller.view.removeFromSuperview()
//                    viewContoller.removeFromParentViewController()
//                }
//            }
//            self.performSegue(withIdentifier: "courseworkTopView", sender: nil)
//        })
    }
    
    func saveButtonPressed2() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10/10), execute: {
            self.calculateTotalPercentageComplete()
            if self.childViewControllers.count > 0 {
                let viewControllers:[UIViewController] = self.childViewControllers
                for viewContoller in viewControllers{
                    viewContoller.willMove(toParentViewController: nil)
                    viewContoller.view.removeFromSuperview()
                    viewContoller.removeFromParentViewController()
                }
            }
//                        self.performSegue(withIdentifier: "courseworkTopView", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "courseworkTopView" {
            if let courseworkDetailController = segue.destination as? CourseWorkDetailViewController {
                courseworkDetailController.courseworkName = coursework?.name
                courseworkDetailController.mark = coursework?.mark
                courseworkDetailController.weight = coursework?.weight
                courseworkDetailController.level = coursework?.level
                courseworkDetailController.startDate = coursework?.startDate
                courseworkDetailController.dueDate = coursework?.dueDate
                courseworkDetailController.notes = coursework?.notes
                courseworkDetailController.completion = coursework?.completion
            }
        }
        
        if segue.identifier == "addTask" {
            if let addTaskController = segue.destination as? AddTaskViewController {
                if isEdit {
                    var currentTask = Task()
                    currentTask = sender as! Task
                    addTaskController.isEdit = true
                    addTaskController.currentTask = currentTask
                }
                addTaskController.currentCoursework = coursework
            }
        }
        isEdit = false
    }
    
    var coursework: Coursework? {
        didSet {
            // Update the view.
        }
    }
    
    // DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            let task = fetchedResultsController.object(at: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! CustomTableViewCell
            cell.deleteCalendarEvent(startDate: task.startDate!, endDate: task.endDate!, courseName: task.name!)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! CustomTableViewCell
        let title = self.fetchedResultsController.fetchedObjects?[indexPath.row].name
        let description = self.fetchedResultsController.fetchedObjects?[indexPath.row].taskDescription
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        let startDate = formatter.string(from: (self.fetchedResultsController.fetchedObjects?[indexPath.row].startDate)! as Date)
        let endDate = formatter.string(from: (self.fetchedResultsController.fetchedObjects?[indexPath.row].endDate)! as Date)
        
        cell.textTitle.text = title
        cell.labelDescription.text = description
        cell.drawProgressBar(strokeEnd: (self.fetchedResultsController.fetchedObjects?[indexPath.row].percentageComplete)!)
        cell.currentTask = (self.fetchedResultsController.fetchedObjects?[indexPath.row])!
        cell.labelStartDate.text = "Start Date: \(startDate)"
        
        cell.labelEndDate.text = "End Date: \(endDate)"
        cell.updateDaysLeftTextField(endDate: (self.fetchedResultsController.fetchedObjects?[indexPath.row].endDate!)!)

        self.numberOfTasks = (self.fetchedResultsController.fetchedObjects?.count)!
        
        if tasks.count != numberOfTasks {
            tasks.insert((self.fetchedResultsController.fetchedObjects?[indexPath.row])!, at: indexPath.row)
        }
        if tasks.count == numberOfTasks {
            tasks.remove(at: indexPath.row)
            tasks.insert((self.fetchedResultsController.fetchedObjects?[indexPath.row])!, at: indexPath.row)
        }
        return cell
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        
        let currentCoursework  = self.coursework
        let request:NSFetchRequest<Task> = Task.fetchRequest()
        request.fetchBatchSize = 20
        
        let albumNameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [albumNameSortDescriptor]
        
        if(self.coursework != nil) {
            let predicate = NSPredicate(format: "coursework = %@", currentCoursework!)
            request.predicate = predicate
        }
        else {
            let predicate = NSPredicate(format: "parentCoursework = %@","Web Tech")
            request.predicate = predicate
            
        }
        
        let frc = NSFetchedResultsController<Task>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Task.parentCoursework),
            cacheName:nil)
        frc.delegate = self
        _fetchedResultsController = frc
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        
        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }
    
    //MARK: - fetch results table view functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            // iOS 8 bug - Do nothing if we get an invalid change type.
            break
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tasks = []
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tasks = []
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        saveButtonPressed2()
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    
    @IBAction func editTask(_ sender: UIButton) {
        let point = sender.superview?.convert(sender.center, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point!) {
            let object = fetchedResultsController.object(at: indexPath)
            isEdit = true
            performSegue(withIdentifier: "addTask", sender: object)
        }
    }
    
}




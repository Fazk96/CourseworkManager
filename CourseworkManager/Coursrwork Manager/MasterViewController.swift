//
//  MasterViewController.swift
//  Coursrwork Manager
//
//  Created by Fazale Khurshid on 04/05/2018.
//  Copyright © 2018 Fazale Khurshid. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var isEdit: Bool = false
    var coursework: Coursework!
    var isChanged: Bool = false
    
    @IBOutlet weak var masterView: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.tintColor = UIColor.white
        navigationItem.title = "Coursework"
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" && !isChanged{
            if let indexPath = tableView.indexPathForSelectedRow {
                let coursework = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.coursework = coursework
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "showDetail" && isChanged{
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.coursework = coursework
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
        
        
        if segue.identifier == "addCoursework" {
            if let addCoursworkController = segue.destination as? AddCourseworkViewController {
                
                if isEdit {
                    var currentCoursework = Coursework()
                    currentCoursework = sender as! Coursework
                    addCoursworkController.isEdit = true
                    addCoursworkController.currentCoursework = currentCoursework
                }
            }
        }
        isEdit = false
        isChanged = false
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseworkCell", for: indexPath) as! MasterTableViewCell
        
        let coursework = fetchedResultsController.object(at: indexPath)
        
        cell.textCoursworkName.text =  coursework.moduleName!
        cell.textModuleName.text = coursework.name!
        
        let daysUntilDeadline = getDaysBetweenTwoDates(startDate: Date(), endDate: coursework.dueDate!)
        
        
        if (daysUntilDeadline.day! < 0) {
            cell.textDaysRemaining.isHidden = false
            cell.textDaysRemaining.text = "Deadline has passed!"
            
        } else if (daysUntilDeadline.day! == 0){
            cell.textDaysRemaining.isHidden = false
            cell.textDaysRemaining.text = "Deadline is today!"
        }
        else {
            cell.updateDaysRemaining(endDate: coursework.dueDate!)
        }
        
        if coursework.completion >= 0.8 {
            cell.backgroundColor = UIColor.init(red: 34/255, green: 168/255, blue: 7/255, alpha: 1) //green
        } else if coursework.completion >= 0.6 && coursework.completion < 0.8 {
            cell.backgroundColor = UIColor.init(red: 232/255, green: 138/255, blue: 14/255, alpha: 1) // orange
        } else {
            cell.backgroundColor = UIColor.red
        }
        
        cell.drawProgressBar(strokeEnd: coursework.completion)
        cell.textCoursworkName.isHidden = false
        
        return cell
    }
    
    func getDaysBetweenTwoDates(startDate:Date, endDate:Date) -> DateComponents {
        let calendar = NSCalendar.current
        
        let calendarDate1 = calendar.startOfDay(for: startDate)
        let calendarDate2 = calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([.day], from: calendarDate1, to: calendarDate2)
        
        return components
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            let coursework = fetchedResultsController.object(at: indexPath)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseworkCell", for: indexPath) as! MasterTableViewCell
            cell.deleteCalendarEventEvent(startDate: coursework.startDate!, endDate: coursework.dueDate!, courseName: coursework.name!)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Coursework> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Coursework> = Coursework.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Coursework>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            let object = fetchedResultsController.object(at: indexPath!)
            coursework = object
            isChanged = true
            performSegue(withIdentifier: "showDetail", sender: nil)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    @IBAction func editCoursework(_ sender: UIButton) {
        let point = sender.superview?.convert(sender.center, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point!) {
            let object = fetchedResultsController.object(at: indexPath)
            isEdit = true
            performSegue(withIdentifier: "addCoursework", sender: object)
        }
    }
}


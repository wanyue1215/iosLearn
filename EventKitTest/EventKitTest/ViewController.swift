//
//  ViewController.swift
//  EventKitTest
//
//  Created by 宛越 on 16/7/5.
//  Copyright © 2016年 yuewan. All rights reserved.
//

import UIKit
import EventKitUI

class RootViewController: UITableViewController {

    var defaultCalendar: EKCalendar?
    var eventStore: EKEventStore?
    var eventsList: NSMutableArray?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        eventStore = EKEventStore()
        
        eventsList = NSMutableArray();
        
        addButton.enabled = false
        
        self.title = "list"
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let addController = EKEventEditViewController()
        addController.eventStore = self.eventStore!
        addController.editViewDelegate = self
        
        
        self.presentViewController(addController, animated: true, completion: nil)
        
        
//        let addController = EKCalendarChooser(selectionStyle: .Multiple, displayStyle: .AllCalendars, entityType: .Event, eventStore: self.eventStore!)
//        
//        self.navigationController?.pushViewController(addController, animated: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkEventStoreAccessForCalendar()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showEventViewController"){
            let eventViewController = segue.destinationViewController as! EKEventViewController
            let inexPath = self.tableView.indexPathForSelectedRow
            eventViewController.event=self.eventsList![inexPath!.row] as! EKEvent
            eventViewController.allowsEditing = true;
            
        }
    }
    
    
    
    //权限检查
    func checkEventStoreAccessForCalendar()
    {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        switch status {
        case .Authorized:
            self.accessGrantedForCalendar();break;
        case .NotDetermined:
            self.requestCalendarAccess();break;
        default: break;
            
        }
        
    }
    
    func accessGrantedForCalendar(){
        defaultCalendar = self.eventStore?.defaultCalendarForNewEvents;
        addButton.enabled = true
        
        self.eventsList = self.fetchEvents()
        self.tableView.reloadData()
    }
    
    func fetchEvents() -> NSMutableArray {
        let startDate = NSDate.init()
        
        let tomorrowDateComponets = NSDateComponents()
        tomorrowDateComponets.day = 1;
        
        let endDate = NSCalendar.currentCalendar().dateByAddingComponents(tomorrowDateComponets, toDate: startDate, options: NSCalendarOptions.WrapComponents)
        
        let calendarArray = [self.defaultCalendar!]
        
        let predicate = self.eventStore?.predicateForEventsWithStartDate(startDate, endDate: endDate!, calendars: calendarArray)
        
        let events = NSMutableArray.init(array: (self.eventStore?.eventsMatchingPredicate(predicate!))!)
        
        return events
    }
    
    func requestCalendarAccess(){
        self.eventStore?.requestAccessToEntityType(EKEntityType.Event, completion: { (granted, error) in
            if(granted) {
                
               self.accessGrantedForCalendar()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsList!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.eventsList![indexPath.row].title
        return cell
    }
}


extension RootViewController: EKCalendarChooserDelegate {
    func calendarChooserDidCancel(calendarChooser: EKCalendarChooser)
    {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
extension RootViewController:EKEventEditViewDelegate {
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendarForNewEvents(controller: EKEventEditViewController) -> EKCalendar {
        return self.defaultCalendar!;
    }
}



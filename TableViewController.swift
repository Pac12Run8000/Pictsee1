//
//  TableViewController.swift
//  Pictsee1
//
//  Created by Michelle Grover on 5/5/16.
//  Copyright © 2016 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
   
    
    var context:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc:NSFetchedResultsController = NSFetchedResultsController()
    
    func getFetchedResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: listFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
          }
    /*** Blahhh ***/

    override func viewDidLoad() {
        super.viewDidLoad()
        //view in customCell
        
        frc = getFetchedResultsController()
        frc.delegate = self
        do {
        try frc.performFetch()
        } catch {
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    
    func listFetchRequest() -> NSFetchRequest{
        let fetchRequest = NSFetchRequest(entityName: "ImageList")
        let sortDescriptor = NSSortDescriptor(key: "desc", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberofsections = (frc.sections?.count)!
        return numberofsections
    
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        let numberOfRowsInSection = frc.sections![section].numberOfObjects
        return numberOfRowsInSection
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        let list = frc.objectAtIndexPath(indexPath) as! ImageList
        if (list.image != nil) {
            cell.cellBgImage.image = UIImage(data: (list.image)!)
        }
        cell.cellLabelCaption.text = list.desc
        cell.cellCustomView.backgroundColor = UIColor.clearColor()
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = cell.cellCustomView.frame.size
        gradient.colors = [UIColor.whiteColor().colorWithAlphaComponent(0).CGColor, UIColor.grayColor().CGColor] //Or any colors
        cell.cellCustomView.layer.addSublayer(gradient)
        
        
        //cell.detailTextLabel?.text = list.desc
        //cell.textLabel?.text = list.title
        //cell.textLabel!.text = String()
       

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(managedObject)
        do {
            try context.save()
        } catch {
            print(error)
            return
        }
        
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editImage") {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let itemController:ViewController = segue.destinationViewController as! ViewController
            let nItem:ImageList = frc.objectAtIndexPath(indexPath!) as! ImageList
            itemController.nImage = nItem
        
        }
    }
    

}

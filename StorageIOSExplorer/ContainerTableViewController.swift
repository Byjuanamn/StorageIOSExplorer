//
//  ContainerTableViewController.swift
//  StorageIOSExplorer
//
//  Created by Juan Antonio Martin Noguera on 11/10/2016.
//  Copyright © 2016 Cloud On Mobile. All rights reserved.
//

import UIKit

class ContainerTableViewController: UITableViewController {

    var client: AZSCloudBlobClient?
    var container: AZSCloudBlobContainer?
    var model: [AZSCloudBlockBlob] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        title = container?.name
        
        readAllBlobs()
        
    }
    
    func readAllBlobs()  {
        
        container?.listBlobsSegmented(with: nil,
                                      prefix: nil,
                                      useFlatBlobListing: true,
                                      blobListingDetails: AZSBlobListingDetails.all,
                                      maxResults: -1,
                                      completionHandler: { (error, results) in
                                        
                                        if let _ = error {
                                            print(error)
                                            return
                                        }
                                        
                                        if !self.model.isEmpty {
                                            self.model.removeAll()
                                        }
                                        
                                        for items in (results?.blobs)! {
                                            self.model.append(items as! AZSCloudBlockBlob)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if model.isEmpty {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
            return 0
        }
        return model.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDABLOB", for: indexPath)
        
        let item = model[indexPath.row]
        cell.textLabel?.text = item.blobName

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

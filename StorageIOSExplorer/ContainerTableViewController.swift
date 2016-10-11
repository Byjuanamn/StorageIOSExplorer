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
        
        uploadBlobWithSAS()
        
    }
    
    @IBAction func addBlobToStorage(_ sender: AnyObject) {
        
        uploadBlob()
    }
    
    func uploadBlob(){
        
        // crear el blob local
        
        let myBlob = container?.blockBlobReference(fromName: UUID().uuidString)
        
        // tomamos una foto o la cogemos de los recursos
        
        let image = UIImage(named: "winter-is-coming.jpg")
        
        // subir
        
        myBlob?.upload(from: UIImageJPEGRepresentation(image!, 0.5)!, completionHandler: { (error) in
            
            if error != nil {
                print(error)
                return
            }
            self.readAllBlobs()

        })
        
    }
    
    func uploadBlobWithSAS()  {
        
        
        do {
            
            let sas = "sv=2015-04-05&ss=b&srt=sco&sp=rwa&se=2016-10-11T22:45:00Z&st=2016-10-11T20:13:53Z&spr=https&sig=whpBrxtJks0EOjRTx77sEcmMmRxX2Bv1iRj1ww2ATiQ%3D"
            
            let credentials = AZSStorageCredentials(sasToken: sas, accountName: "boot3labs")
            
            let accout = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            let client = accout.getBlobClient()
            
            
            let conti = client?.containerReference(fromName: (self.container?.name)!)
            
            let theBlob = conti?.blockBlobReference(fromName: UUID().uuidString)
            // tomamos una foto o la cogemos de los recursos
            
            let image = UIImage(named: "winter-is-coming.jpg")
            
            // subir
            
            theBlob?.upload(from: UIImageJPEGRepresentation(image!, 0.5)!, completionHandler: { (error) in
                
                if error != nil {
                    print(error)
                    return
                }
                self.readAllBlobs()
                
            })
            
            
        
        } catch let ex {
            print(ex)
        }
        
    }
    
    
    func downloadBlobFromStorage(_ theBlob: AZSCloudBlockBlob) {
        
        theBlob.downloadToData { (error, data) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if let _ = data {
                var img = UIImage(data: data!)
                print("Imagen ok")
            }
            
        }
        
    }
    
    func eraseBlobBlock(_ theBlob: AZSCloudBlockBlob) {
        
        theBlob.delete { (error) in
            
            if let _ = error {
                print(error)
                return
            }
            
            self.readAllBlobs()
            
        }
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
    

    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.model[indexPath.row]
        
        downloadBlobFromStorage(item)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            let item = self.model[indexPath.row]
            model.remove(at: indexPath.row)
            self.eraseBlobBlock(item)
            
            tableView.endUpdates()
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

}

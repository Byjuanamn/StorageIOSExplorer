//
//  ContainersTableViewController.swift
//  StorageIOSExplorer
//
//  Created by Juan Antonio Martin Noguera on 10/10/2016.
//  Copyright © 2016 Cloud On Mobile. All rights reserved.
//

import UIKit

class ContainersTableViewController: UITableViewController {

    var client: AZSCloudBlobClient?
    
    var model: [AZSCloudBlobContainer] = []
    
    
    
    func setupAzureClient()  {
        
        do {
            let credentials = AZSStorageCredentials(accountName: "boot3labs",
                                                    accountKey: "UqCIJKhpmuyEOuyxInGx5v0hDCZLPzOZax1cy15KMEAYDTsvmei1A6w0klOMmgbS58cjsLzO/8RR+BcK2z3WvA==")
            let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            client = account.getBlobClient()
            
            self.readAllContainers()
            
        } catch let error {
            print(error)
        }
        
    }
    
    
    func readAllContainers()  {
        
        client?.listContainersSegmented(with: nil,
                                        prefix: nil,
                                        containerListingDetails: AZSContainerListingDetails.all,
                                        maxResults: -1,
                                        completionHandler: { (error, containersResults) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if !self.model.isEmpty {
                self.model.removeAll()
            }
            
            
            for item in (containersResults?.results)! {
                print(item)
                self.model.append((item as? AZSCloudBlobContainer)!)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
        })
        
    }
    
    func newContainer(_ name: String) {
        
        let blobContainer = client?.containerReference(fromName: name.lowercased())
        
        blobContainer?.createContainerIfNotExists(with: AZSContainerPublicAccessType.container,
                                                  requestOptions: nil,
                                                  operationContext: nil,
                                                  completionHandler: { (error, result) in
            
            if let _  = error {
                print(error)
                return
            }
            
            if result {
                print("Exito ....... Container creado")
                self.readAllContainers()
            } else {
                print("Ya existe y no lo vuelvo a crear")
            }

        })
    }
    
    func eraseContainer(_ container: AZSCloudBlobContainer)  {
        container.deleteIfExists { (error, results) in
            
            if let _ = error {
                print(error)
                return
            }
            if results {
                self.readAllContainers()
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        setupAzureClient()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addNewContainer(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Nuevo Container", message: "Escribe un nombre de 3 a 24 caracteres", preferredStyle: .alert)
        
        
        let actionOk = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            let nameContainer = alert.textFields![0] as UITextField
            print("Boton OK --> \(nameContainer.text)")
            self.newContainer(nameContainer.text!)
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        alert.addTextField { (textField) in
            
            textField.placeholder = "Introduce un nombre para el container"
            
        }
        present(alert, animated: true, completion: nil)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDA", for: indexPath)

        // Configure the cell...
        
        let item = model[indexPath.row]

        cell.textLabel?.text = item.name
        
        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            let container = self.model[indexPath.row]
            self.model.remove(at: indexPath.row)
            self.eraseContainer(container)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.model[indexPath.row]
        
        performSegue(withIdentifier: "selectContainer", sender: item)
    }
 
   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "selectContainer" {
            
            let vc = segue.destination as! ContainerTableViewController
            vc.client = client
            vc.container = sender as? AZSCloudBlobContainer
            
        }
    }
    

}












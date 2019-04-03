//
//  ViewController.swift
//  SQLite Persistence
//
//  Created by student on 4/2/19.
//  Copyright © 2019 Sean Klechak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lineFields:[UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var database:OpaquePointer? = nil
        var result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to Open Database")
            return
        }
        let createSQL = "CREATE TABLE IF NOT EXISTS FIELDS " + "(ROW INTEGER PRIMARY KEY, FIELD_DATA TEXT);"
        var errMSG:UnsafeMutablePointer<Int8>? = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMSG)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("failed to create table")
            return
        }
        let query = "SELECT ROW, FEILD_+DATA FROM FIELDS ORDER BY ROW"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let row = Int(sqlite3_column_int(statement, 0))
                let rowData = sqlite3_column_text(statement, 1)
//                let rowData = sqlite3_column_text(statement, 1)
                // This book has too many errors. Not issues with deprication / upgrades..but actual errors.  Would not recommend.
                let fieldValue = String(cString:rowData!)
                lineFields[row].text = fieldValue
                
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
//        let app = UIApplication.shared()
        
        let app = UIApplication.shared
        //ddObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: Notification.Name.UIApplicationWillResignActive, obect: app)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: Notification.Name.UIApplication.willResignActiveNotification, object: app)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: app)

        
    }
    
    func dataFilePath() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var url:String?
        url = ""  // Create a blank Path
        
        do {
            try url = urls.first?.appendingPathComponent("data.plist").path
        } catch {
            print("Error is \(error)")
        }
        return url!
    }
    
    @objc func applicationWillResignActive(notification:NSNotification) {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(dataFilePath(), &database)
        if result !=  SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        for i in 0..<lineFields.count {
        let field = lineFields[i]
            let update = "INSERT OR REPLACE INTO FIELDS (ROW, FIELD_DATA) " + "VALUES (?, ?)";
            var statement:OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                let text = field.text
                sqlite3_bind_int(statement, 1, Int32(i))
                sqlite3_bind_text(statement, 2, text!, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error updating table")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
    }
        sqlite3_close(database)
}

}


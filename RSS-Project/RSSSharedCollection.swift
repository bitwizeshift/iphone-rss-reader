//
//  RSSSharedCollection.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Class: RSSSharedCollection
//
// I personally hate myself for using this, since I absolutely loath singletons.
//
// This class is used to hold a single instance of an RSSCollection to be used
// by the app.
//
class RSSSharedCollection{

    //------------------------------------------------------------------------
    // MARK: - Private Attributes
    //------------------------------------------------------------------------
    
    private static var instance : RSSSharedCollection? = nil;
    private var collection : RSSCollection = RSSCollection();
    
    //------------------------------------------------------------------------
    // MARK: - Instantiation
    //------------------------------------------------------------------------
    
    //
    // Gets the shared instance of this class
    //
    static func getInstance() -> RSSSharedCollection {
        if RSSSharedCollection.instance == nil {
            RSSSharedCollection.instance = RSSSharedCollection()
        }
        return RSSSharedCollection.instance!
    }
    
    //------------------------------------------------------------------------
    // MARK: - Accessor
    //------------------------------------------------------------------------
    
    //
    // Gets the shared RSS Collection
    //
    func getCollection() -> RSSCollection{
        return collection
    }
    
    //------------------------------------------------------------------------
    // MARK: - Serialization
    //------------------------------------------------------------------------

    //
    // Acquires the path to the data file
    //
    private static func dataFilePath( filename : String ) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.stringByAppendingPathComponent( filename ) as String
    }

    //
    // Saves an RSSCollection to the file manager
    //
    func save( filename : String, rootKey : String ){
        let filePath = RSSSharedCollection.dataFilePath( filename )
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject( collection, forKey: rootKey )
        archiver.finishEncoding()
        data.writeToFile(filePath, atomically: true)
    }
    
    //
    // Loads an RSSCollection from the file manager
    //
    func load( filename : String, rootKey : String ){
        let filePath = RSSSharedCollection.dataFilePath( filename )
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
            let data       = NSMutableData(contentsOfFile: filePath)!
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            
            // If the deck does not exist, construct a new one
            if let optCollection = unarchiver.decodeObjectForKey( rootKey ) as? RSSCollection{
                collection = optCollection
            }
            unarchiver.finishDecoding()
        }
    }
    
}
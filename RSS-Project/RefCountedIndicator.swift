//
//  RefCountedIndicator.swift
//  RSS-Project
//
//  Created by Matthew on 2016-03-20.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import UIKit

//
// Class: RefCountedIndicator
//
// This class is a simple reference-counter used to record when the network
// activity indicator should be disabled.
//
// It uses thread-synchronization to increment/decrement a count, only
// disabling the indicator when all operations being waited on have completed.
//
// This ensures that the indicator light does not accidentally get disabled
// pre-emptively
//
class RefCountedIndicator{
    
    //------------------------------------------------------------------------
    // MARK: - Private Members
    //------------------------------------------------------------------------
    
    private var count : Int32 = 0
    
    //------------------------------------------------------------------------
    // MARK: - Enable/Disable Indicator
    //------------------------------------------------------------------------

    //
    // Enables the network activity indicator.
    //
    // This call increments the internal count for the indicator each time it
    // is called
    //
    func enable(){
        objc_sync_enter(self)
        if(count==0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        count++
        objc_sync_exit(self)
    }
    
    //
    // Attempts to disable the network activity indicator.
    //
    // This call decrements the internal count. If the count reaches 0, then it
    // means all current operations have completed and it is safe to disable the
    // indicator.
    //
    func disable(){
        objc_sync_enter(self)
        count--
        if(count==0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        objc_sync_exit(self)
    }
}
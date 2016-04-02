//
//  Stack.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-04-02.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

private class StackNode<T> {
    var value: T?
    var next: StackNode?
}

class Stack<T>{

    //----------------------------------------------------------------------------
    // Private Members
    //----------------------------------------------------------------------------
    
    private var top : StackNode<T>? = nil

    //----------------------------------------------------------------------------
    // Stack API
    //----------------------------------------------------------------------------
    
    //
    // Pushes a value onto the stack
    //
    func push(value: T){
        let node = StackNode<T>()
        node.value = value;
        node.next = top
        top = node
    }
    
    //
    // Pops a value from the stack
    //
    func pop() -> T?{
        if top != nil{
            let node = top!
            top = top!.next
            return node.value
        }else{
            return nil
        }
    }
    
    //
    // Peeks a value from the top of the stack
    //
    func peek() -> T?{
        if let top = top{
            return top.value
        }else{
            return nil
        }
    }
}
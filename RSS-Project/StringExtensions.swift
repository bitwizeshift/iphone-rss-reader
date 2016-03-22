//
//  StringExtensions.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Extensions to the default String library
//
// There are not nearly enough features built into it, and so this
// is here to help facilitate many missing features
//
extension String{
    
    //
    // Checks equality by ignoring the case-sensitivity of the string
    //
    func equalsIgnoreCase( other : String ) -> Bool{
        return self.uppercaseString == other.uppercaseString;
    }
    
    //
    // Simple String replace feature. Replaces the target with the specified string
    //
    func replace(target: String, withString: String) -> String{
        
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    //
    // Simple substring method between two indices
    //
    func substring( fromIndex: Index, toIndex: Index ) -> String{
        return self.substringFromIndex( fromIndex ).substringToIndex( toIndex )
    }
    
    //
    // Implementation of string index searching
    //
    func indexOf(target: String) -> Index?{
        let range = self.rangeOfString(target)
        if let range = range {
            return range.startIndex
        } else {
            return nil
        }
    }
    
    //
    // Implementation of string index searching from a starting index point
    //
    func indexOf(target: String, startIndex: Index) -> Index?{
        let substr = self.substringFromIndex( startIndex )
        
        let range = substr.rangeOfString(target)
        if let range = range {
            return range.startIndex
        } else {
            return nil
        }
    }
    
    //
    // Trims this string of all leading and trailing whitespace characters
    //
    func trim() -> String{
        return self.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet() )
    }
}
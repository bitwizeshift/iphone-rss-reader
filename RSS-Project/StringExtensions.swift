//
//  StringExtensions.swift
//  RSS-Project
//
//  Created by Matthew Rodusek on 2016-03-19.
//  Copyright © 2016 Wilfrid Laurier University. All rights reserved.
//

import Foundation

//
// Dictionary of character entities to decode in HTML
//
private let characterEntities : [ String : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">"
    
]

private let characterToEntity : [ Character : String ] = [
    "\"" : "&quot;",
    "&"  : "&amp;",
    "'"  : "&apos;",
    "<"  : "&lt;",
    ">"  : "&gt;"
]
//
// Extensions to the default String library
//
// There are not nearly enough features built into it, and so this
// is here to help facilitate many missing features
//
extension String{

    //------------------------------------------------------------------------
    // String Escaping
    //------------------------------------------------------------------------
    
    // SOURCE: http://stackoverflow.com/a/30141700

    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var unescapedHTMLString : String {
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(string : String, base : Int32) -> Character? {
            let code = UInt32(strtoul(string, nil, base))
            return Character(UnicodeScalar(code))
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(entity : String) -> Character? {
            
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X"){
                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(3)), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(2)), base: 10)
            } else {
                return characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self.rangeOfString("&", range: position ..< endIndex) {
            result.appendContentsOf(self[position ..< ampRange.startIndex])
            position = ampRange.startIndex
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            if let semiRange = self.rangeOfString(";", range: position ..< endIndex) {
                let entity = self[position ..< semiRange.endIndex]
                position = semiRange.endIndex
                
                if let decoded = decode(entity) {
                    // Replace by decoded character:
                    result.append(decoded)
                } else {
                    // Invalid entity, copy verbatim:
                    result.appendContentsOf(entity)
                }
            } else {
                // No matching ';'.
                break
            }
        }
        // Copy remaining characters to `result`:
        result.appendContentsOf(self[position ..< endIndex])
        return result
    }
    
    //
    // Removes all HTML tags from a string and extracts the text from it
    //
    var detaggedString : String{
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil).trim()
    }
    
    //------------------------------------------------------------------------
    // Mark: - Equality and replacement
    //------------------------------------------------------------------------
    
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
    
    
    //------------------------------------------------------------------------
    // Mark: - Subscripting
    //------------------------------------------------------------------------

    //
    // Subscripts the string to retrieve an individual character
    //
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    //
    // Subscripts the string to retrieve an individual character as a string
    //
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    //
    // Subscripts the string to retrieve a substring from a String given a range
    //
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}
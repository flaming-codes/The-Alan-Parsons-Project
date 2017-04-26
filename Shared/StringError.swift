//
//  StringError.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 12.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

enum StringError : Error {
    case nonEmptyRequiered(String)
}

//
//  StringExtension.swift
//  QrReader
//
//  Created by jrangel on 18/01/21.
//

import Foundation


extension String {

    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

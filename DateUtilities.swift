//
//  Date.swift
//  jobagent
//
//  Created by Brenden West on 7/7/17.
//
//

import UIKit

class DateUtilities {

    enum DateFormat: String {
        case long = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case short = "MM/dd/yyyy"
    }
    
    private static var dateFormatterLong: DateFormatter {
        let _dateFormatter = DateFormatter()
        _dateFormatter.locale = Locale.current
        _dateFormatter.dateFormat = DateFormat.long.rawValue
        return _dateFormatter
    }
    
    private static var dateFormatterShort: DateFormatter {
        let _dateFormatter = DateFormatter()
        _dateFormatter.locale = Locale.current
        _dateFormatter.dateFormat = DateFormat.short.rawValue
        return _dateFormatter
    }
    
    static func dateFrom(string: String, format: DateFormat) -> Date? {
        switch format {
        case .long:
            return dateFormatterLong.date(from: string)
        case .short:
            return dateFormatterShort.date(from: string)
        }
    }
    
    static func dateStringFrom(date: Date, format: DateFormat) -> String {
        switch format {
        case .long:
            return dateFormatterLong.string(from: date)
        case .short:
            return dateFormatterShort.string(from: date)
        }
    }

    static func dateStringFrom(string: String) -> String {
        // return short date string for long input
        let date = dateFormatterLong.date(from: string)
        return dateFormatterShort.string(from: date!)
    }

}

//
//  Date+Extension.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/21/24.
//

import Foundation

extension Date {
    static func createdDate(dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString) ?? Date()
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    static func formatToISO8601String(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] //소수 초 포함
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

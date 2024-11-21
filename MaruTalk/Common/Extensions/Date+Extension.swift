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
}

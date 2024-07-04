//
//  ServerErrorModel.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import Foundation

struct ServerErrorModel: Codable {
    let code: String
    let status: Int?
    let message: String
}

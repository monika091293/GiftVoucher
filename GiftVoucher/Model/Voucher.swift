//
//  Voucher.swift
//  GiftVoucher
//
//  Created by MONIKA MOHAN on 20/07/22.
//

import Foundation


public struct Voucher {
    public let id: Int
    public let title: String
    public let card: String
    public let img: String
}

extension Voucher: Hashable {
    public static func == (lhs: Voucher, rhs: Voucher) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(img)
    }
}

extension Voucher: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case card = "card"
        case img = "img"
    }
}

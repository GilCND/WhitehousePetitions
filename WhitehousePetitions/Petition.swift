//
//  Petition.swift
//  WhitehousePetitions
//
//  Created by Felipe Gil on 2021-06-11.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}

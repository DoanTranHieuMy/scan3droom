//
//  CaptureRoomData.swift
//  RoomCaptureApp
//
//  Created by Vuong Doan on 04/12/2023.
//

import Foundation
import RoomPlan

struct StoreCapture {
    static var shared = StoreCapture()
    public var dataCapture: [ModelDataCapture] = []
    
    public mutating func addCaptureData(data: ModelDataCapture) {
        self.dataCapture.append(data)
    }
    
    public mutating func removeCaptureDataByIndex(index: Int) {
        self.dataCapture.remove(at: index)
    }
    
}

struct ModelDataCapture: Codable {
    var url: URL?
    let data: CapturedStructure?
    var filePath: String
    let creationDate: Date
    var nameUSDZ: String
    var isFavorite: Bool = false
}

enum ModelCaptureType {
    case JSON
    case USDZ
    case AIOutput
}


struct ScannedModel {
    let filePath: String
    let name: String
}

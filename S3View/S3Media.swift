//
//  S3Media.swift
//  KomsudaPisti
//
//  Created by Erdi on 23.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import Foundation

/// Media type
public enum S3MediaType: Int {
    
    case image
    case video
}

public class S3Media {
    
    public let type: S3MediaType
    public let url: String
    
    public init(type: S3MediaType, url: String) {
        
        self.type = type
        self.url = url
    }
}

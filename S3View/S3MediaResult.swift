//
//  S3MediaResult.swift
//  KomsudaPisti
//
//  Created by Erdi on 27.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import Foundation

/// S3Media result type
public enum S3MediaResult {
    
    case success(S3Media)
    case failure(Error)
}

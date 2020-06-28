//
//  S3MediaUtils.swift
//  KomsudaPisti
//
//  Created by Erdi on 27.06.2020.
//  Copyright © 2020 Komsuda. All rights reserved.
//

import Foundation

final class S3MediaUtils {
    
    /// Creates url at temporary directory with given key name
    /// - Parameter keyName: Media key name
    static func url(with keyName: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(keyName)
    }
}

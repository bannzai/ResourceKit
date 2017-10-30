//
//  ImportOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/23.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public protocol ImportOutput: Output {
    
}

public struct ImportOutputImpl: ImportOutput {
    public let writeUrl: URL
    public let config: Config
    
    public init(
        writeUrl: URL,
        config: Config
        ) {
        self.writeUrl = writeUrl
        self.config = config
    }
    
    func imports() -> [String] {
        guard let content = try? String(contentsOf: writeUrl) else {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        let pattern = "\\s*import\\s+.+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .useUnixLineSeparators) else {
            return ["import UIKit"]
        }
        let results = regex.matches(in: content, options: [], range: NSMakeRange(0, content.characters.count))
        
        if results.isEmpty {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        
        return results.flatMap { (result) -> String? in
            if result.range.location != NSNotFound {
                let matchingString = (content as NSString).substring(with: result.range) as String
                return matchingString
                    .replacingOccurrences(of: "\n", with: "")
            }
            return nil
        }
    }

    public var declaration: String {
        return imports().joined(separator: Const.newLine)
    }
}

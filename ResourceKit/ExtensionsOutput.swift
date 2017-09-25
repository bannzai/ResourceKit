//
//  ExtensionsOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/23.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

struct ExtensionsOutputImpl {
    let reusableProtocolContent: String = [
        "protocol Reusable {",
        "   associatedtype View",
        "   var name: String { get }",
        "}",
    ].joined(separator: newLine)
    
    let xibProtocolContent: String = [
        "protocol XibProtocol: Reusable {",
        "\(tab1)func nib() -> UINib",
        "\(tab1)func view() -> View",
        "}",
    ].joined(separator: newLine)
    
    let tableViewExtensionContent: String = [
        "extension UITableView {",
        "\(tab1)func register<X: XibProtocol>(XibProtocol: X) -> Void where X.View: UITableViewCell {",
        "\(tab2)register(XibProtocol.nib(), forCellReuseIdentifier: XibProtocol.name)",
        "\(tab1)}",
        "    ",
        "\(tab1)func register<X: XibProtocol>(xibs: [X]) -> Void where X.View: UITableViewCell {",
        "\(tab2)xibs.forEach { register(XibProtocol: $0) }",
        "\(tab1)}",
        "    ",
        "\(tab2)func dequeueReusableCell<X: Reusable>(with XibProtocol: X, for indexPath: IndexPath) -> X.View where X.View: UITableViewCell {",
        "\(tab3)return dequeueReusableCell(withIdentifier: XibProtocol.name, for: indexPath) as! X.View",
        "\(tab2)}",
        "}",
        ].joined(separator: newLine)
    
    let collectionViewExtensionContent = [
        "extension UICollectionView {",
        "\(tab1)func register<X: XibProtocol>(XibProtocol: X) -> Void where X.View: UICollectionViewCell {",
        "\(tab2)register(XibProtocol.nib(), forCellWithReuseIdentifier: XibProtocol.name)",
        "\(tab1)}",
        "    ",
        "\(tab1)func register<X: XibProtocol>(xibs: [X]) -> Void where X.View: UICollectionViewCell {",
        "\(tab2)xibs.forEach { register(XibProtocol: $0) }",
        "\(tab1)}",
        "    ",
        "\(tab1)func dequeueReusableCell<X: Reusable>(with XibProtocol: X, for indexPath: IndexPath) -> X.View where X.View: UICollectionViewCell {",
        "\(tab2)return dequeueReusableCell(withReuseIdentifier: XibProtocol.name, for: indexPath) as! X.View",
        "\(tab1)}",
        "}",
    ].joined(separator: newLine)
}

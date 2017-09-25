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
        "protocol ReusableProtocol {",
        "   associatedtype View",
        "   var name: String { get }",
        "}",
    ].joined(separator: newLine)
    
    let xibProtocolContent: String = [
        "protocol XibProtocol: ReusableProtocol {",
        "\(tab1)func nib() -> UINib",
        "\(tab1)func view() -> View",
        "}",
    ].joined(separator: newLine)
    
    let tableViewExtensionContent: String = [
        "extension UITableView {",
        "\(tab1)func register<X: XibProtocol>(xib: X) -> Void where X.View: UITableViewCell {",
        "\(tab2)register(xib.nib(), forCellReuseIdentifier: xib.name)",
        "\(tab1)}",
        "    ",
        "\(tab1)func register<X: XibProtocol>(xibs: [X]) -> Void where X.View: UITableViewCell {",
        "\(tab2)xibs.forEach { register(xib: $0) }",
        "\(tab1)}",
        "    ",
        "\(tab2)func dequeueReusableCell<R: ReusableProtocol>(with reusable: R, for indexPath: IndexPath) -> R.View where R.View: UITableViewCell {",
        "\(tab3)return dequeueReusableCell(withIdentifier: reusable.name, for: indexPath) as! R.View",
        "\(tab2)}",
        "}",
        ].joined(separator: newLine)
    
    let collectionViewExtensionContent = [
        "extension UICollectionView {",
        "\(tab1)func register<X: XibProtocol>(xib: X) -> Void where X.View: UICollectionViewCell {",
        "\(tab2)register(xib.nib(), forCellWithReuseIdentifier: xib.name)",
        "\(tab1)}",
        "    ",
        "\(tab1)func register<X: XibProtocol>(xibs: [X]) -> Void where X.View: UICollectionViewCell {",
        "\(tab2)xibs.forEach { register(xib: $0) }",
        "\(tab1)}",
        "    ",
        "\(tab1)func dequeueReusableCell<R: ReusableProtocol>(with reusable: R, for indexPath: IndexPath) -> R.View where R.View: UICollectionViewCell {",
        "\(tab2)return dequeueReusableCell(withReuseIdentifier: reusable.name, for: indexPath) as! R.View",
        "\(tab1)}",
        "}",
    ].joined(separator: newLine)
}

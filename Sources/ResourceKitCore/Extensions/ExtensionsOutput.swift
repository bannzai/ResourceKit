//
//  ExtensionsOutput.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/23.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation

public struct ExtensionsOutputImpl {
    public init() { }
    public let reusableProtocolContent: String = [
        "protocol ReusableProtocol {",
        "   associatedtype View",
        "   static var name: String { get }",
        "}",
    ].joined(separator: Const.newLine)
    
    public let xibProtocolContent: String = [
        "protocol XibProtocol: ReusableProtocol {",
        "\(Const.tab1)static func nib() -> UINib",
        "\(Const.tab1)static func view() -> View",
        "}",
    ].joined(separator: Const.newLine)
    
    public let tableViewExtensionContent: String = [
        "extension UITableView {",
        "\(Const.tab1)func register<X: XibProtocol>(xib: X.Type) -> Void where X.View: UITableViewCell {",
        "\(Const.tab2)register(xib.nib(), forCellReuseIdentifier: xib.name)",
        "\(Const.tab1)}",
        "    ",
        "\(Const.tab1)func register<X: XibProtocol>(xibs: [X.Type]) -> Void where X.View: UITableViewCell {",
        "\(Const.tab2)xibs.forEach { register(xib: $0) }",
        "\(Const.tab1)}",
        "    ",
        "\(Const.tab1)func dequeueReusableCell<R: ReusableProtocol>(with reusable: R.Type, for indexPath: IndexPath) -> R.View where R.View: UITableViewCell {",
        "\(Const.tab2)return dequeueReusableCell(withIdentifier: reusable.name, for: indexPath) as! R.View",
        "\(Const.tab1)}",
        "}",
        ].joined(separator: Const.newLine)
    
    public let collectionViewExtensionContent = [
        "extension UICollectionView {",
        "\(Const.tab1)func register<X: XibProtocol>(xib: X.Type) -> Void where X.View: UICollectionViewCell {",
        "\(Const.tab2)register(xib.nib(), forCellWithReuseIdentifier: xib.name)",
        "\(Const.tab1)}",
        "    ",
        "\(Const.tab1)func register<X: XibProtocol>(xibs: [X.Type]) -> Void where X.View: UICollectionViewCell {",
        "\(Const.tab2)xibs.forEach { register(xib: $0) }",
        "\(Const.tab1)}",
        "    ",
        "\(Const.tab1)func dequeueReusableCell<R: ReusableProtocol>(with reusable: R.Type, for indexPath: IndexPath) -> R.View where R.View: UICollectionViewCell {",
        "\(Const.tab2)return dequeueReusableCell(withReuseIdentifier: reusable.name, for: indexPath) as! R.View",
        "\(Const.tab1)}",
        "}",
    ].joined(separator: Const.newLine)
}

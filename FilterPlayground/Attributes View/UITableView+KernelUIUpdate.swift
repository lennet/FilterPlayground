//
//  UITableView+KernelUIUpdate.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 27.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

extension UITableView {
    func apply(changes: [KernelUIUpdate], section: Int) {
        var insertions: [IndexPath] = []
        var deletions: [IndexPath] = []
        var reloads: [IndexPath] = []
        for change in changes {
            switch change {
            case let .insertion(row):
                insertions.append(IndexPath(row: row, section: section))
                break
            case let .deletion(row):
                deletions.append(IndexPath(row: row, section: section))
                break
            case let .update(row, argument):
                if case let cell as KernelAttributeTableViewCell = cellForRow(at: IndexPath(row: row, section: section)) {
                    cell.attribute = argument
                }
                break
            case let .reload(row):
                reloads.append(IndexPath(row: row, section: section))
                break
            }
        }
        deleteRows(at: deletions, with: .none)
        reloadRows(at: reloads, with: .none)
        insertRows(at: insertions, with: .none)
    }
}

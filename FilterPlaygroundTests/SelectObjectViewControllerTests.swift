//
//  SelectObjectViewControllerTests.swift
//  FilterPlaygroundTests
//
//  Created by Leo Thomas on 29.12.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

@testable import FilterPlayground
import XCTest

struct MockPrensentable: SelectObjectViewControllerPresentable {
    var image: UIImage? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }

    var title: String
    var subtitle: String?
    var index: Int
}

class SelectObjectViewControllerTests: XCTestCase {
    func testPresentTitle() {
        let objects = [MockPrensentable(title: "foo", subtitle: "bar", index: 0), MockPrensentable(title: "a", subtitle: "b", index: 1)]
        let callBack: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void = { _, _ in }
        let viewController = SelectObjectViewController(objects: [objects], callback: callBack)
        viewController.loadViewIfNeeded()

        let firstIndexPath = IndexPath(row: 0, section: 0)
        let secondIndexPath = IndexPath(row: 1, section: 0)
        let dataSource = viewController.tableView.dataSource!
        let firstCell = dataSource.tableView(viewController.tableView, cellForRowAt: firstIndexPath)
        let secondCell = dataSource.tableView(viewController.tableView, cellForRowAt: secondIndexPath)

        XCTAssertEqual(firstCell.textLabel?.text, objects.first?.title)
        XCTAssertEqual(firstCell.detailTextLabel?.text, objects.first?.subtitle)

        XCTAssertEqual(secondCell.textLabel?.text, objects.last?.title)
        XCTAssertEqual(secondCell.detailTextLabel?.text, objects.last?.subtitle)
    }

    func testSelectObjectCallback() {
        let exp = expectation(description: "waiting for selection")
        let expectedIndex = 1
        let objects = [MockPrensentable(title: "foo", subtitle: "bar", index: 0), MockPrensentable(title: "a", subtitle: "b", index: 1)]
        let callBack: (SelectObjectViewControllerPresentable, SelectObjectViewController) -> Void = { object, _ in
            XCTAssertEqual((object as! MockPrensentable).index, expectedIndex)
            exp.fulfill()
        }
        let viewController = SelectObjectViewController(objects: [objects], callback: callBack)

        let selectedIndexPath = IndexPath(row: expectedIndex, section: 0)

        viewController.tableView.delegate?.tableView?(viewController.tableView, didSelectRowAt: selectedIndexPath)
        wait(for: [exp], timeout: 1)
    }
}

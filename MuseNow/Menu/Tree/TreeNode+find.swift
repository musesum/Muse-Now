//
//  TreeNode+find.swift
//  MuseNow
//
//  Created by warren on 2/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNode {

    func find(str:String) -> MenuCell! {
        // first search childing, breadth first
        for child in children {
            if child.name.starts(with:str) {
                return child.cell
            }
        }
        // otherwise go broadly deep - O(n) with shortcut for most common match at top
        for child in children {
            if let cell = child.find(str: name) {
                return cell
            }
        }
        return nil
    }

    func findPath(_ path:String) -> MenuCell! {
        let paths = path.split {$0 == "."}.map(String.init)
        return TreeNodes.shared.root?.find(paths,0) ?? nil
    }

    func find(_ paths:[String],_ index:Int) -> MenuCell! {
        if let cell = find(str:paths[index]) {
            return index == paths.count-1
                ? cell
                : cell.treeNode.find(paths,index+1)
        }
        return nil
    }


    /// find node matching title, and then animate to that cell, if needed

    func goto(path:String, finish:@escaping CallBaseNode) {

        var lineage = [TreeNode]()

        func nextLineage() {
            let node = lineage.popLast()!
            if lineage.isEmpty {
                // always collapse destination to save space
                node.cell?.touchCell(.zero, isExpandable:false)
                Timer.delay(0.25) { finish(node) }
            }
            else if node.expanded == false {
                node.cell?.touchCell(.zero)
                nextLineage()
            }
            else {
                nextLineage()
            }
        }

        // begin ------------------------------

        if name.starts(with: path) {
            finish(self)
        }
        else if let cell = findPath(path) {

            var node = cell.treeNode!
            while node.parent != nil {
                lineage.append(node)
                node = node.parent!
            }
            nextLineage()
        }
        else {
            finish(self) /// this used to be nil
        }
    }

}
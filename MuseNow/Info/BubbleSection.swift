//
//  TourSection.swift
//  MuseNow
//
//  Created by warren on 1/4/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

class TourSection {

    var title: String
    var bubbles = [Bubble]()
    var tourSet: TourSet!

    init(_ title_:String,_ tourSet_:TourSet,_ bubbles_:[Bubble?]) {

        title = title_
        tourSet = tourSet_

        for bubble in bubbles_ {
            if let bubble = bubble {
                bubbles.append(bubble)
            }
        }
        if !tourSet.intersection([.main,.menu]).isEmpty {
            Tour.shared.tourBubbles.append(contentsOf: bubbles)
        }
    }
}


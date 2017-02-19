//
//  Actions.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-18.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import GameplayKit

class Actions {
    
    @available(iOS 10.0, *)
    static func getFlipAction(texture: SKTexture, duration: TimeInterval) -> SKAction {
        let originalPositions: [vector_float2] = [
            vector_float2(0, 0), vector_float2(1, 0),
            vector_float2(0, 1), vector_float2(1, 1)
        ]
        let flipFirstHalfDestinationPositions: [vector_float2] = [
            vector_float2(0.5, 0.0), vector_float2(0.5, -0.1),
            vector_float2(0.5, 1.0), vector_float2(0.5, 1.1)
        ]
        let switchDestinationPositions: [vector_float2] = [
            vector_float2(0.5, -0.1), vector_float2(0.5, 0.0),
            vector_float2(0.5, 1.1), vector_float2(0.5, 1.0)
        ]
        
        let flipFirstHalfFlipGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: originalPositions, destinationPositions: flipFirstHalfDestinationPositions)
        let switchGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: originalPositions, destinationPositions: switchDestinationPositions)
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1)
        let switchWarp = SKAction.warp(to: switchGeometryGrid, duration: 0)
        
        let flipFirstHalfWarp = SKAction.warp(to: flipFirstHalfFlipGeometryGrid, duration: duration)
        let flipFirstHalfShade = SKAction.colorize(with: .gray, colorBlendFactor: 1, duration: duration)
        let flipFirstHalfMove = SKAction.move(by: CGVector(dx: 20, dy: 10), duration: duration)
        let flipFirstHalgGroup = SKAction.group([flipFirstHalfWarp!, flipFirstHalfShade, flipFirstHalfMove])
        
        let textureChange = SKAction.setTexture(texture)
        
        let flipSecondHalfWarp = SKAction.warp(to: warpGeometryGridNoWarp, duration: duration)
        let flipSecondHalfShade = SKAction.colorize(withColorBlendFactor: 0, duration: duration)
        let flipSecondHalfMove = SKAction.move(by: CGVector(dx: -20, dy: -10), duration: duration)
        let flipSecondHalfGroup = SKAction.group([flipSecondHalfWarp!, flipSecondHalfShade, flipSecondHalfMove])
        
        return SKAction.sequence([flipFirstHalgGroup,
                                  textureChange,
                                  switchWarp!,
                                  flipSecondHalfGroup])
    }
    
    static func getPopAction(originalScale: CGFloat, scaleBy: CGFloat, duration: TimeInterval) -> SKAction {
        let popUp = SKAction.scale(by: scaleBy, duration: duration / 2)
        let popDown = SKAction.scale(to: originalScale, duration: duration / 2)
        return SKAction.sequence([popUp, popDown])
    }
}

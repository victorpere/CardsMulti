//
//  ScoresViewController.swift
//  CardsMulti
//
//  Created by Victor on 2020-04-05.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import UIKit

class ScoresViewController : UIViewController {
    
    var scene: GameScene
    
    var gridView: GridView
    
    // MARK: - Initializers
    
    init(withScene scene: GameScene) {
        self.scene = scene
        self.gridView = GridView(rowSize: scene.peers.count, rowHeight: 30)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Scores"
        
        self.view.addSubview(self.gridView)
        for peer in scene.peers {
            let peerLabel = UILabel(frame: .zero)
            peerLabel.text = peer?.displayName
            self.gridView.addCell(view: peerLabel)
        }
    }
}

//
//  ScoreView.swift
//  CardsMulti
//
//  Created by Victor on 2020-04-05.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import UIKit

class GridView : UIStackView {
    
    // MARK: - Private properties
    
    private var cells: [UIView] = []
    
    private var currentRow: GridRow?
    
    // MARK: - Properties
    
    let rowSize: Int
    
    let rowHeight: CGFloat
    
    // MARK: - Computed properties
    
    var lastRowComplete: Bool {
        return self.cells.count % self.rowSize == 0
    }
    
    var fakeCellCount: Int {
        return (self.rowSize - self.cells.count % self.rowSize) % self.rowSize
    }
    
    // MARK: - Initializers
    
    init(rowSize: Int, rowHeight: CGFloat) {
        self.rowSize = rowSize
        self.rowHeight = rowHeight
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func addCell(view: UIView) {
        if self.currentRow == nil || self.lastRowComplete {
            self.currentRow = GridRow()
            self.addArrangedSubview(self.currentRow!)
        }
        
        for _ in 0..<self.fakeCellCount {
            self.currentRow!.removeArrangedSubview(self.currentRow!.arrangedSubviews.last!)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: self.rowHeight).isActive = true
        self.cells.append(view)
        self.currentRow!.addArrangedSubview(view)
        
        if !self.lastRowComplete {
            for _ in 0..<self.fakeCellCount {
                self.currentRow!.addArrangedSubview(FakeCell())
            }
        }
    }
}

// MARK: - GridRow class

class GridRow : UIStackView {
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FakeCell class

class FakeCell : UIView {
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

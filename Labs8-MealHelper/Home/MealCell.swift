//
//  MealCell.swift
//  Labs8-MealHelper
//
//  Created by Simon Elhoej Steinmejer on 08/11/18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit

class MealCell: UICollectionViewCell {
    
    var meal: Meal? {
        didSet {
            setupViews()
        }
    }
    // TODO: To be deleted
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // TODO: To be deleted
        addSubview(nameLabel)
        
        nameLabel.fillSuperview()
        
        nameLabel.text = meal?.mealTime
    }
    
}

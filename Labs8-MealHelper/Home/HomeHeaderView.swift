//
//  HomeHeaderView.swift
//  Labs8-MealHelper
//
//  Created by Simon Elhoej Steinmejer on 13/11/18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {

    let progressIndicator = ProgressIndicator(frame: CGRect.zero, progress: 1800.0, goal: 2000.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(progressIndicator)
        
        progressIndicator.centerInSuperview(size: CGSize(width: 250.0, height: 250.0))
    }
    
}

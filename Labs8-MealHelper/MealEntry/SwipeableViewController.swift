//
//  SwipeableViewController.swift
//  Labs8-MealHelper
//
//  Created by De MicheliStefano on 23.11.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case intermediate
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .intermediate
        case .closed: return .intermediate
        case .intermediate: return .open
        }
    }
}

class SwipableViewController: UIViewController {
    
    var openHeight: CGFloat = 650.0
    var closedHeight: CGFloat = 200.0
    var popupOffset: CGFloat {
        return openHeight - closedHeight
    }
    
    private var currentState: State = .intermediate
    private var animationProgress: CGFloat = 0.0
    private var viewIsAnimating = false
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 30
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private var bottomConstraint = NSLayoutConstraint()
    private var transitionAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private func setupViews() {
        view.addSubview(overlayView)
        
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(popupView)
        
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: openHeight).isActive = true
        
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: openHeight - closedHeight)
        bottomConstraint.isActive = true
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: popupView)
        let isSwipingUp = translation.y < 0 ? true : false
        var fraction = -translation.y / popupOffset
        
        switch recognizer.state {
            //        case .began:
            //            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            //            animationProgress = transitionAnimator?.fractionComplete ?? 0.0
        //            viewIsAnimating = true
        case .changed:
            if currentState == .intermediate && !viewIsAnimating {
                if isSwipingUp {
                    animateTransitionIfNeeded(to: .open, duration: 1.0)
                    transitionAnimator?.pauseAnimation()
                    animationProgress = transitionAnimator?.fractionComplete ?? 0.0
                    viewIsAnimating = true
                } else {
                    animateTransitionIfNeeded(to: .closed, duration: 1.0)
                    transitionAnimator?.pauseAnimation()
                    animationProgress = transitionAnimator?.fractionComplete ?? 0.0
                    viewIsAnimating = true
                }
            } else if currentState == .open && !viewIsAnimating {
                animateTransitionIfNeeded(to: .intermediate, duration: 1.0)
                transitionAnimator?.pauseAnimation()
                animationProgress = transitionAnimator?.fractionComplete ?? 0.0
                viewIsAnimating = true
            }
            
            if currentState == .open || transitionAnimator?.isReversed ?? false { fraction *= -1 }
            
            if currentState == .intermediate && !isSwipingUp  { fraction *= -1 }
            
            transitionAnimator?.fractionComplete = fraction + animationProgress // Add previous animation progress to panned fraction
        case .ended:
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldMoveDown = yVelocity > 0
            if yVelocity == 0 {
                transitionAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            
            switch currentState { // Reverse the animations based on their current state and pan motion
            case .open:
                if !shouldMoveDown && !(transitionAnimator?.isReversed ?? false) { transitionAnimator?.isReversed = !(transitionAnimator?.isReversed ?? false) }
                if shouldMoveDown && transitionAnimator?.isReversed ?? false { transitionAnimator?.isReversed = !(transitionAnimator?.isReversed ?? false) }
            case .intermediate:
                if !shouldMoveDown && transitionAnimator?.isReversed ?? false { transitionAnimator?.isReversed = !(transitionAnimator?.isReversed ?? false) }
            case .closed:
                break
            }
            
            transitionAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.overlayView.alpha = 0.3
            case .intermediate:
                self.bottomConstraint.constant = self.popupOffset
                self.overlayView.alpha = 0
            case .closed:
                self.bottomConstraint.constant = self.openHeight
                self.overlayView.alpha = 0
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator?.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite // state == .closed ? .intermediate : state.opposite
            case .end:
                self.currentState = state // Update state when animation ended
            case .current:
                ()
            }
            
            self.viewIsAnimating = false
        }
        
        transitionAnimator?.startAnimation()
    }
    
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
    
}

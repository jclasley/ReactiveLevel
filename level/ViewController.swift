//
//  ViewController.swift
//  level
//
//  Created by Jonathan Lasley on 9/17/20.
//  Copyright © 2020 Jonathan Lasley. All rights reserved.
//

import UIKit
import CoreMotion
import RxSwift

class ViewController: UIViewController {

	@IBOutlet var levelDot: UIView!
	var positiveMax: (x: CGFloat, y: CGFloat)!
	
	override func viewDidLoad() {
		levelDot.center = self.view.center
		super.viewDidLoad()
		positiveMax = (view.frame.maxX, view.frame.maxY)
		initGryo()
	}

	fileprivate func initGryo() {
		let pitch = PublishSubject<Double>()
		let roll = PublishSubject<Double>()
		let motion = CMMotionManager()
		guard motion.isDeviceMotionAvailable else { return }
		motion.deviceMotionUpdateInterval = 1/60
		motion.startDeviceMotionUpdates()
		let gyroTimer = Timer(fire: Date(), interval: 1/60, repeats: true, block: { timer in
			if let attitude = motion.deviceMotion?.attitude {
				let yModifier: CGFloat = 1.3
				
				_ = pitch.map( { (self.positiveMax!.y + CGFloat($0)*self.positiveMax!.y * yModifier) })
					.map( {$0 / 2} )
					.subscribe(onNext: { centerY in
						// not too high so the dot is offscreen
						
						guard centerY < self.positiveMax.y else {
							self.levelDot.center.y = self.positiveMax.y
							return
						}
						guard centerY > 0 else {
							self.levelDot.center.y = 0
							return
						}
						self.levelDot.center.y = centerY
						
					})
				pitch.onNext(attitude.pitch)
				
				let xModifier: CGFloat = 1.15
				_ = roll.map( { (self.positiveMax!.x + CGFloat($0)*self.positiveMax!.x*xModifier) })
					.map({ $0 / 2 })
					.subscribe(onNext: { centerX in
						guard centerX < self.positiveMax.x else {
							self.levelDot.center.x = self.positiveMax.x
							return
						}
						guard centerX > 0 else {
							self.levelDot.center.x = 0
							return
						}
						self.levelDot.center.x = centerX
					})
				roll.onNext(attitude.roll)
				
				// convert to value that will be passed to center
			}
		})
		RunLoop.current.add(gyroTimer, forMode: .default)
		
	}
	
}


extension UIView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
		set {
			self.layer.cornerRadius = newValue
		}
	}
}

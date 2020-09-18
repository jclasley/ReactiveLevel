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
				_ = pitch.map( { (self.positiveMax!.y + CGFloat($0)*self.positiveMax!.y) / 2 })
					.subscribe(onNext: { centerY in
						// not too high so the dot is offscreen
						let modifiedCenter = centerY * 1.3
						guard modifiedCenter < self.positiveMax.y else {
							self.levelDot.center.y = self.positiveMax.y
							return
						}
						guard modifiedCenter > 0 else {
							self.levelDot.center.y = 0
							return
						}
						self.levelDot.center.y = modifiedCenter
						
					})
				pitch.onNext(attitude.pitch)
				_ = roll.map( { (self.positiveMax!.x + CGFloat($0)*self.positiveMax!.x) / 2})
					.subscribe(onNext: { centerX in
						let modifiedCenter = centerX * 1.2
						guard modifiedCenter < self.positiveMax.x else {
							self.levelDot.center.x = self.positiveMax.x
							return
						}
						guard modifiedCenter > 0 else {
							self.levelDot.center.x = 0
							return
						}
						self.levelDot.center.x = modifiedCenter
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

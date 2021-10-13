//
//  Created by Thang Nguyen on 7/2/21.
//

import UIKit

class CustomSegue1: UIStoryboardSegue {
	
	override func perform() {
		destination.transitioningDelegate = self
		
		/// if set segue kind in StoryBoard to custom:
		//		source.present(destination, animated: true, completion: nil)
		/// else
		super.perform()
	}
}

extension CustomSegue1: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return Presenter()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return Presenter()
	}
	
	private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
		func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
			return 10
		}
		
		func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
			//			NSLog("--  \(TAG) | containerView \(transitionContext.containerView)")
			//			NSLog("--  \(TAG) | from \(transitionContext.viewController(forKey: .from)) | \(transitionContext.view(forKey: .from))")
			//			NSLog("--  \(TAG) | to \(transitionContext.viewController(forKey: .to)) | \(transitionContext.view(forKey: .to))")
			
			let fromView = transitionContext.view(forKey: .from)
			let toView = transitionContext.view(forKey: .to)!
			
			transitionContext.containerView.addSubview(toView)
			toView.alpha = 0
			UIView.animateKeyframes(withDuration: 0.8,
									delay: 0,
									options: .calculationModeLinear,
									animations: {
										UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
											fromView?.alpha = 0
										}
										UIView.addKeyframe(withRelativeStartTime: 0.7,relativeDuration: 0.3) {
											toView.alpha = 1
										}
									}) { _ in
				fromView?.alpha = 1
				transitionContext.completeTransition(true)
			}
		}
	}
}

class CustomSegue2: UIStoryboardSegue {
	
	override func perform() {
		destination.transitioningDelegate = self
		
		/// if set segue kind in StoryBoard to custom:
		//		source.present(destination, animated: true, completion: nil)
		/// else
		super.perform()
	}
}

extension CustomSegue2: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return Presenter()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return Presenter()
	}
	
	private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
		func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
			return 10
		}
		
		func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
			//			NSLog("--  \(TAG) | containerView \(transitionContext.containerView)")
			//			NSLog("--  \(TAG) | from \(transitionContext.viewController(forKey: .from) as Any) | \(transitionContext.view(forKey: .from) as Any)")
			//			NSLog("--  \(TAG) | to \(transitionContext.viewController(forKey: .to) as Any) | \(transitionContext.view(forKey: .to) as Any)")
			
			let fromView = transitionContext.view(forKey: .from)
			let toView = transitionContext.view(forKey: .to)!
			
			transitionContext.containerView.addSubview(toView)
			toView.alpha = 0
			UIView.animateKeyframes(withDuration: 0.3,
									delay: 0,
									options: .calculationModeLinear,
									animations: {
										UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
											fromView?.alpha = 0
										}
										UIView.addKeyframe(withRelativeStartTime: 0.7,relativeDuration: 0.3) {
											toView.alpha = 1
										}
									}) { _ in
				fromView?.alpha = 1
				transitionContext.completeTransition(true)
			}
		}
	}
}

//
//  Created by Thang Nguyen on 7/5/21.
//

import UIKit

public class ScaleFrame: UIImageView {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		contentMode = .scaleToFill
		setResizedImage(image: image!)
	}
	
	func setResizedImage(image: UIImage) {
		self.image = image.resizableImage(
			withCapInsets: UIEdgeInsets(top: image.size.height * 0.3, left: image.size.width * 0.3,
												 bottom: image.size.height * 0.3, right: image.size.width * 0.3),
			resizingMode: .stretch)
	}
}

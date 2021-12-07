//
//  Created by Thang Nguyen on 6/29/21.
//

public struct Utils {
	
	private static let TAG = "🧰"
	
	public static func factors(of n: Int) -> [Int]? {
		// precondition(n > 0, "n must be positive")
		if n <= 0 { return nil }
		
		let sqrtn = Int(Double(n).squareRoot())
		var factors: [Int] = []
		factors.reserveCapacity(2 * sqrtn)
		for i in 1...sqrtn {
			if n % i == 0 {
				factors.append(i)
			}
		}
		var j = factors.count - 1
		if factors[j] * factors[j] == n {
			j -= 1
		}
		while j >= 0 {
			factors.append(n / factors[j])
			j -= 1
		}
		return factors
	}
}

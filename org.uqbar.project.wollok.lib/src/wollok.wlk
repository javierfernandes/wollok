/**
 * Base class for all Exceptions.
 * 
 * @author jfernandes
 * @since 1.0
 */
package lang {
 
	/**
	 * Base class for all Exceptions.
	 * 
	 * @author jfernandes
	 * @since 1.0
	 */
	class Exception {
		method printStackTrace() native	
	}
	
	/**
	 *
	 * @author jfernandes
	 * since 1.0
	 */
	class WObject {
		method identity() native
		
		method ==(other) {
			return self === other
		}
		
		method ->(other) {
			return new Pair(self, other)
		}
	}
	
	class Pair {
		val x
		val y
		new (_x, _y) {
			x = _x
			y = _y
		}
		method getX() { return x }
		method getY() { return y }
		method getKey() { self.getX() }
		method getValue() { self.getY() }
	}
 
}
 
package lib {
	object console {
		method println(obj) native
		method readLine() native
		method readInt() native
	}
	
	object assert {
		method that(value) native
		method notThat(value) native
		method equals(expected, actual) native
		method notEquals(expected, actual) native
	}
	
}

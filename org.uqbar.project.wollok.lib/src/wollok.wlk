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
		const message
		const cause
	
		constructor()
		constructor(_message) = self(_message, null)
		constructor(_message, _cause) { message = _message ; cause = _cause }
		
		method printStackTrace() { self.printStackTrace(console) }
		method getStackTraceAsString() {
			const printer = new StringPrinter()
			self.printStackTrace(printer)
			return printer.getBuffer()
		}
		
		method printStackTrace(printer) { self.printStackTraceWithPreffix("", printer) }
		
		/** @private */
		method printStackTraceWithPreffix(preffix, printer) {
			printer.println(preffix +  self.className() + (if (message != null) (": " + message.toString()) else "")
			
			// TODO: eventually we will need a stringbuffer or something to avoid memory consumption
			self.getStackTrace().forEach { e =>
				printer.println("\tat " + e.contextDescription() + " [" + e.location() + "]")
			}
			
			if (cause != null)
				cause.printStackTraceWithPreffix("Caused by: ", printer)
		}
		
		/** @private */
		method createStackTraceElement(contextDescription, location) = new StackTraceElement(contextDescription, location)
		
		method getStackTrace() native
		
		method getMessage() = message
	}
	
	class ElementNotFoundException inherits Exception {
		constructor(_message) = super(_message)
		constructor(_message, _cause) = super(_message, _cause)
	}

	class MessageNotUnderstoodException inherits Exception {
		constructor()
		constructor(_message) = super(_message)
		constructor(_message, _cause) = super(_message, _cause)
		
		/*
		'''«super.getMessage()»
			«FOR m : wollokStack»
			«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
			«ENDFOR»
			'''
		*/
	}
	
	class StackTraceElement {
		const contextDescription
		const location
		constructor(_contextDescription, _location) {
			contextDescription = _contextDescription
			location = _location
		}
		method contextDescription() = contextDescription
		method location() = location
	}
	
	/**
	 *
	 * @author jfernandes
	 * since 1.0
	 */
	class Object {
		method identity() native
		method instanceVariables() native
		method instanceVariableFor(name) native
		method resolve(name) native
		method kindName() native
		method className() native
		
		/**
		 * Tells whether self object is "equals" to the given object
		 * The default behavior compares them in terms of identity (===)
		 */
		method ==(other) {
			return self === other
		}
		
		/** Tells whether self object is not equals to the given one */
		method !=(other) = ! (self == other)
		
		/**
		 * Tells whether self object is identical (the same) to the given one.
		 * It does it by comparing their identities.
		 * So self basically relies on the wollok.lang.Integer equality (which is native)
		 */
		method ===(other) {
			return self.identity() == other.identity()
		}
		
		method equals(other) = self == other
		
		method randomBetween(start, end) native
		
		method ->(other) {
			return new Pair(self, other)
		}
		
		method randomBetween(start, end) native
		
		method toString() {
			// TODO: should be a set
			// return self.toSmartString(#{})
			return self.toSmartString([])
		}
		method toSmartString(alreadyShown) {
			if (alreadyShown.any { e => e.identity() == self.identity() } ) { 
				return self.kindName() 
			}
			else {
				alreadyShown.add(self)
				return self.internalToSmartString(alreadyShown)
			}
		} 
		method internalToSmartString(alreadyShown) {
			return self.kindName() + "[" 
				+ self.instanceVariables().map { v => 
					v.name() + "=" + v.valueToSmartString(alreadyShown)
				}.join(', ') 
			+ "]"
		}
		
		method messageNotUnderstood(name, parameters) {
			var message = if (name != "toString") 
						self.toString()
					 else 
					 	self.kindName()
			message += " does not understand " + name
			if (parameters.size() > 0)
				message += "(" + (0..(parameters.size()-1)).map { i => "p" + i }.join(',') + ")"
			else
				message += "()"
			throw new MessageNotUnderstoodException(message)
		}
		
		method error(message) {
			throw new Exception(message)
		}
	}
	
	object void { }
	
	
	class Pair {
		const x
		const y
		constructor (_x, _y) {
			x = _x
			y = _y
		}
		method getX() { return x }
		method getY() { return y }
		method getKey() { return self.getX() }
		method getValue() { return self.getY() }
	}
	
	class Collection {
		/**
		  * Returns the element that is considered to be/have the maximum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["a", "ab", "abc", "d" ].max { e => e.length() }    =>  returns "abc"		 
		  */
		method max(closure) = self.absolute(closure, { a, b => a > b })
		
		/**
		  * Returns the element that is considered to be/have the minimum value.
		  * The criteria is given by a closure that receives a single element as input (one of the element)
		  * The closure must return a comparable value (something that understands the >, >= messages).
		  * Example:
		  *       ["ab", "abc", "hello", "wollok world"].max { e => e.length() }    ->  returns "wollok world"		 
		  */
		method min(closure) = self.absolute(closure, { a, b => a < b} )
		
		method absolute(closure, criteria) {
			const result = self.fold(null, { acc, e =>
				const n = closure.apply(e) 
				if (acc == null)
					new Pair(e, n)
				else {
					if (criteria.apply(n, acc.getY()))
						new Pair(e, n)
					else
						acc
				}
			})
			return if (result == null) null else result.getX()
		}
		 
		// non-native methods
		
		/**
		  * Adds all elements from the given collection parameter to self collection
		  */
		method addAll(elements) { elements.forEach { e => self.add(e) } }
		
		/** Tells whether self collection has no elements */
		method isEmpty() = self.size() == 0
				
		/**
		 * Performs an operation on every elements of self collection.
		 * The logic to execute is passed as a closure that takes a single parameter.
		 * @returns nothing
		 * Example:
		 *      plants.forEach { plant => plant.takeSomeWater() }
		 */
		method forEach(closure) { self.fold(null, { acc, e => closure.apply(e) }) }
		
		/**
		 * Tells whether all the elements of self collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.all { plant => plant.hasFlowers() }
		 */
		method all(predicate) = self.fold(true, { acc, e => if (!acc) acc else predicate.apply(e) })
		
		/**
		 * Tells whether at least one element of self collection satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns true/false
		 * Example:
		 *      plants.any { plant => plant.hasFlowers() }
		 */
		method any(predicate) = self.fold(false, { acc, e => if (acc) acc else predicate.apply(e) })
		
		/**
		 * Returns the element of self collection that satisfy a given condition.
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition
		 * @throws ElementNotFoundException if no element matched the given predicate
		 * Example:
		 *      users.find { user => user.name() == "Cosme Fulanito" }
		 */
		method find(predicate) = self.findOrElse(predicate, { 
			throw new ElementNotFoundException("there is no element that satisfies the predicate")
		})

		/**
		 * Returns the element of self collection that satisfy a given condition, or the given default otherwise, if no element matched the predicate
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition or the default value
		 * Example:
		 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, homer)
		 */
		method findOrDefault(predicate, value) =  self.findOrElse(predicate, { value })
		
		/**
		 * Returns the element of self collection that satisfy a given condition, 
		 * or the the result of evaluating the given continuation 
		 * If more than one element satisfies the condition then it depends on the specific collection class which element
		 * will be returned
		 * @returns the element that complies the condition or the result of evaluating the continuation
		 * Example:
		 *      users.findOrElse({ user => user.name() == "Cosme Fulanito" }, { homer })
		 */
		method findOrElse(predicate, continuation) native


		/**
		 * Counts all elements of self collection that satisfy a given condition
		 * The condition is a closure argument that takes a single element and returns a number.
		 * @returns an integer number
		 * Example:
		 *      plants.count { plant => plant.hasFlowers() }
		 */
		method count(predicate) = self.fold(0, { acc, e => if (predicate.apply(e)) acc++ else acc })
		/**
		 * Collects the sum of each value for all e
		 * This is similar to call a map {} to transform each element into a number object and then adding all those numbers.
		 * The condition is a closure argument that takes a single element and returns a boolean value.
		 * @returns an integer
		 * Example:
		 *      const totalNumberOfFlowers = plants.sum { plant => plant.numberOfFlowers() }
		 */
		method sum(closure) = self.fold(0, { acc, e => acc + closure.apply(e) })
		
		/**
		 * Returns a new collection that contains the result of transforming each of self collection's elements
		 * using a given closure.
		 * The condition is a closure argument that takes a single element and returns an object.
		 * @returns another collection (same type as self one)
		 * Example:
		 *      const ages = users.map{ user => user.age() }
		 */
		method map(closure) = self.fold(self.newInstance(), { acc, e =>
			 acc.add(closure.apply(e))
			 acc
		})
		
		method flatMap(closure) = self.fold(self.newInstance(), { acc, e =>
			acc.addAll(closure.apply(e))
			acc
		})

		method filter(closure) = self.fold(self.newInstance(), { acc, e =>
			 if (closure.apply(e))
			 	acc.add(e)
			 acc
		})

		method contains(e) = self.any {one => e == one }
		method flatten() = self.flatMap { e => e }
		
		override method internalToSmartString(alreadyShown) {
			return self.toStringPrefix() + self.map{ e => e.toSmartString(alreadyShown) }.join(', ') + self.toStringSufix()
		}
		
		method toStringPrefix()
		method toStringSufix()
		method asList()
		method asSet()
		method copy() {
			var copy = self.newInstance()
			copy.addAll(self)
			return copy
		}
		method sortedBy(closure) = self.copy().asList().sortBy(closure)
		
		method newInstance()
	}

	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */	
	class Set inherits Collection {
		constructor(elements ...) {
			self.addAll(elements)
		}
		
		override method newInstance() = #{}
		override method toStringPrefix() = "#{"
		override method toStringSufix() = "}"
		
		override method asList() { 
			const result = []
			result.addAll(self)
			return result
		}
		
		override method asSet() = self

		override method anyOne() native
		
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method findOrElse(predicate, continuation) native
		method add(element) native
		method remove(element) native
		method size() native
		method clear() native
		method join(separator) native
		method join() native
		method equals(other) native
		method ==(other) native
	}
	
	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 */
	class List inherits Collection {

		method get(index) native
		
		override method newInstance() = []
		
		method anyOne() {
			if (self.isEmpty()) 
				throw new Exception("Illegal operation 'anyOne' on empty collection")
			else 
				return self.get(self.randomBetween(0, self.size()))
		}
		
		method first() = self.head()
		method head() = self.get(0)
		
		override method toStringPrefix() = "["
		override method toStringSufix() = "]"

		override method asList() = self
		
		override method asSet() { 
			const result = #{}
			result.addAll(self)
			return result
		}
		
		method subList(start,end) {
			if(self.isEmpty)
				return self.newInstance()
			const newList = self.newInstance()
			const _start = start.limitBetween(0,self.size()-1)
			const _end = end.limitBetween(0,self.size()-1)
			(_start.._end).forEach { i => newList.add(self.get(i)) }
			return newList
		}
		 
		method sortBy(closure) native
		
		method take(n) =
			if(n <= 0)
				self.newInstance()
			else
				self.subList(0,n-1)
			
		
		method drop(n) = 
			if(n >= self.size())
				self.newInstance()
			else
				self.subList(n,self.size()-1)
			
		
		method reverse() = self.subList(self.size()-1,0)
	
		// REFACTORME: DUP METHODS
		method fold(initialValue, closure) native
		method findOrElse(predicate, continuation) native
		method add(element) native
		method remove(element) native
		method size() native
		method clear() native
		method join(separator) native
		method join() native
		method equals(other) native
		method ==(other) native
	}
	
	/**
	 *
	 * @author flbulgarelli
	 * @since 1.4
	 */
	class Dictionary {
		method values() native
		method keys() native
		
		method map(closure) native
		method filter(closure) native
		
		method anyOne() = self.values().anyOne()
		
		method any(closure) = self.values().any(closure)
		method all(closure) = self.values().all(closure)
		method find(closure) = self.values().find(closure)
		method sum(closure) = self.values().sum(closure)
		method max(closure) = self.values().max(closure)
		method min(closure) = self.values().min(closure)
		method count(closure) = self.values().count(closure)
		method contains(value) = self.values().contains(value)
		method fold(initialValue, closure) = self.values().fold(initialValue, closure)
		method join(separator) = self.values().join(separator)
		method join() = self.values().join()
		
		method isEmpty() = self.keys().isEmpty()
		method size() = self.keys().size()
		method containsKey(key) = self.keys().contains(key)
		
		override method internalToSmartString(alreadyShown) {
			return "{" + self.keys().map{ k => k.toString() + ':' + self.get(k).toString() }.join(', ') + '}'
		}
			
		method put(key, value) native
		method removeKey(key) native
		method get(key) native

		method clear() native

		method equals(other) native
		method ==(other) native
	}

	/**
	 *
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */	
	class Number {
	
		method max(other) = if (self >= other) self else other
		method min(other) = if (self <= other) self else other
		
		method limitBetween(limitA,limitB) = if(limitA <= limitB) 
												limitA.max(self).min(limitB) 
											 else 
											 	limitB.max(self).min(limitA)
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Integer inherits Number {
		// the whole wollok identity impl is based on self method
		method ===(other) native
	
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method **(other) native
		method %(other) native
		
		method toString() native
		
		override method internalToSmartString(alreadyShown) { return self.stringValue() }
		method stringValue() native	
		
		method ..(end) = new Range(self, end)
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native

		/**
		 * Executes the given action as much times as the receptor object
		 */
		method times(action) = (1..self).forEach(action)
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Double inherits Number {
		// the whole wollok identity impl is based on self method
		method ===(other) native
	
		method +(other) native
		method -(other) native
		method *(other) native
		method /(other) native
		method **(other) native
		method %(other) native
		
		method toString() native
		
		override method internalToSmartString(alreadyShown) { return self.stringValue() }
		method stringValue() native	
		
		method >(other) native
		method >=(other) native
		method <(other) native
		method <=(other) native
		
		method abs() native
		method invert() native
	}
	
	/**
	 * @author jfernandes
	 * @noInstantiate
	 */
	class String {
		method length() native
		method charAt(index) native
		method +(other) native
		method startsWith(other) native
		method endsWith(other) native
		method indexOf(other) native
		method lastIndexOf(other) native
		method toLowerCase() native
		method toUpperCase() native
		method trim() native
		
		method substring(length) native
		method substring(startIndex, length) native

		method toString() native
		method toSmartString(alreadyShown) native
		method ==(other) native
		
		
		method size() = self.length()
	}
	
	/**
	 * @author jfernandes
	 * @noinstantiate
	 */
	class Boolean {
	
		method and(other) native
		method &&(other) native
		
		method or(other) native
		method ||(other) native
		
		method toString() native
		method toSmartString(alreadyShown) native
		method ==(other) native
		
		method negate() native
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 */
	class Range {
		const start
		const end
		constructor(_start, _end) { start = _start ; end = _end }
		
		method forEach(closure) native
		
		method map(closure) {
			const l = []
			self.forEach { e => l.add(closure.apply(e)) }
			return l
		}
		
		override method internalToSmartString(alreadyShown) = start.toString() + ".." + end.toString()
	}
	
	/**
	 * @author jfernandes
	 * @since 1.3
	 * @noInstantiate
	 */
	class Closure {
		method apply(parameters...) native
		method toString() native
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
		method throwsException(block) native
		method fail(message) native
	}
	
	class StringPrinter {
		var buffer = ""
		method println(obj) {
			buffer += obj.toString() + "\n"
		}
		method getBuffer() = buffer
	}	
	
	object wgame {
		method addVisual(element) native
		method addVisualIn(element, position) native
		method addVisualCharacter(element) native
		method addVisualCharacterIn(element, position) native
		method removeVisual(element) native
		method whenKeyPressedDo(key, action) native
		method whenKeyPressedSay(key, function) native
		method whenCollideDo(element, action) native
		method getObjectsIn(position) native
		method say(element, message) native
		method clear() native
		method start() native
		method stop() native
		
		method setTitle(title) native
		method getTitle() native
		method setWidth(width) native
		method getWidth() native
		method setHeight(height) native
		method getHeight() native
		method setGround(image) native
	}
	
	class Position {
		var x = 0
		var y = 0
		
		constructor() { }		
				
		constructor(_x, _y) {
			x = _x
			y = _y
		}
		
		method moveRight(num) { x += num }
		method moveLeft(num) { x -= num }
		method moveUp(num) { y += num }
		method moveDown(num) { y -= num }
	
		method drawElement(element) { wgame.addVisualIn(element, self) }
		method drawCharacter(element) { wgame.addVisualCharacterIn(element, self) }		
		method deleteElement(element) { wgame.removeVisual(element) }
		method say(element, message) { wgame.say(element, message) }
		method allElements() = wgame.getObjectsIn(self)
		
		method clone() = new Position(x, y)

		method clear() {
			self.allElements().forEach{it => wgame.removeVisual(it)}
		}
		
		method getX() = x
		method setX(_x) { x = _x }
		method getY() = y
		method setY(_y) { y = _y }
	}
}

package game {
		
	class Key {	
		var keyCodes
		
		constructor(_keyCodes) {
			keyCodes = _keyCodes
		}
	
		method onPressDo(action) {
			keyCodes.forEach{ key => wgame.whenKeyPressedDo(key, action) }
		}
		
		method onPressCharacterSay(function) {
			keyCodes.forEach{ key => wgame.whenKeyPressedSay(key, function) }
		}
	}

	object ANY_KEY inherits Key([-1]) { }
  
	object NUM_0 inherits Key([7, 144]) { }
	
	object NUM_1 inherits Key([8, 145]) { }
	
	object NUM_2 inherits Key([9, 146]) { }
	
	object NUM_3 inherits Key([10, 147]) { }
	
	object NUM_4 inherits Key([11, 148]) { }
	
	object NUM_5 inherits Key([12, 149]) { }
	
	object NUM_6 inherits Key([13, 150]) { }
	
	object NUM_7 inherits Key([14, 151]) { }
	
	object NUM_8 inherits Key([15, 152]) { }
	
	object NUM_9 inherits Key([16, 153]) { }
	
	object A inherits Key([29]) { }
	
	object ALT inherits Key([57, 58]) { }
	
	object B inherits Key([30]) { }
  
	object BACKSPACE inherits Key([67]) { }
	
	object C inherits Key([31]) { }
  
	object CONTROL inherits Key([129, 130]) { }
  
	object D inherits Key([32]) { }
	
	object DEL inherits Key([67]) { }
  
	object CENTER inherits Key([23]) { }
	
	object DOWN inherits Key([20]) { }
	
	object LEFT inherits Key([21]) { }
	
	object RIGHT inherits Key([22]) { }
	
	object UP inherits Key([19]) { }
	
	object E inherits Key([33]) { }
	
	object ENTER inherits Key([66]) { }
	
	object F inherits Key([34]) { }
	
	object G inherits Key([35]) { }
	
	object H inherits Key([36]) { }
	
	object I inherits Key([37]) { }
	
	object J inherits Key([38]) { }
	
	object K inherits Key([39]) { }
	
	object L inherits Key([40]) { }
	
	object M inherits Key([41]) { }
	
	object MINUS inherits Key([69]) { }
	
	object N inherits Key([42]) { }
	
	object O inherits Key([43]) { }
	
	object P inherits Key([44]) { }
	
	object PLUS inherits Key([81]) { }
	
	object Q inherits Key([45]) { }
	
	object R inherits Key([46]) { }
	
	object S inherits Key([47]) { }
	
	object SHIFT inherits Key([59, 60]) { }
	
	object SLASH inherits Key([76]) { }
	
	object SPACE inherits Key([62]) { }
	
	object T inherits Key([48]) { }
	
	object U inherits Key([49]) { }
	
	object V inherits Key([50]) { }
	
	object W inherits Key([51]) { }
	
	object X inherits Key([52]) { }
	
	object Y inherits Key([53]) { }
	
	object Z inherits Key([54]) { }
}

package mirror {

	class InstanceVariableMirror {
		const target
		const name
		constructor(_target, _name) { target = _target ; name = _name }
		method name() = name
		method value() = target.resolve(name)
		
		method valueToSmartString(alreadyShown) {
			const v = self.value()
			return if (v == null) "null" else v.toSmartString(alreadyShown)
		}

		method toString() = name + "=" + self.value()
	}
}

package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * @author jfernandes
 */
class ListTestCase extends AbstractWollokInterpreterTestCase {
	
	def instantiateCollectionAsNumbersVariable() {
		"val numbers = #[22, 2, 10]"
	}
	
	@Test
	def void testSize() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testContains() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.contains(22))
			assert.that(numbers.contains(2))
			assert.that(numbers.contains(10))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testRemove() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			numbers.remove(22)		
			assert.that(2 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testClear() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			numbers.clear()		
			assert.that(0 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testIsEmpty() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.notThat(numbers.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testForEach() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			
			var sum = 0
			numbers.forEach([n | sum += n])
			
			assert.equals(34, sum)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAll() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var allPositives = numbers.all([n | n > 0])
			assert.that(allPositives)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAllWhenItIsFalse() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var allPositives = numbers.all([n | n > 5])
			assert.notThat(allPositives)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFilter() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var greaterThanFiveElements = numbers.filter([n | n > 5])
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMap() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var halfs = numbers.map([n | n / 2])

			assert.that(halfs.contains(11))
			assert.that(halfs.contains(5))
			assert.that(halfs.contains(1))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testShortCutAvoidingParenthesis() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var greaterThanFiveElements = numbers.filter[n | n > 5]
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAnyOne() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			val any = numbers.anyOne()
			assert.that(numbers.contains(any))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testEqualsWithMethodName() {
		'''
		program p {
			val a = #[23, 2, 1]
			val b = #[23, 2, 1]
			assert.that(a.equals(b))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testEqualsWithEqualsEquals() {
		'''
		program p {
			val a = #[23, 2, 1]
			val b = #[23, 2, 1]
			assert.that(a == b)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToString() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals("#[22, 2, 10]", numbers.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToStringWithObjectRedefiningToStringInWollok() {
		'''
		object myObject {
			method toString() = "My Object"
		}
		program p {
			val a = #[23, 2, 1, myObject]
			assert.equals("#[23, 2, 1, My Object]", a.toString())
		}'''.interpretPropagatingErrors
	}
	
}
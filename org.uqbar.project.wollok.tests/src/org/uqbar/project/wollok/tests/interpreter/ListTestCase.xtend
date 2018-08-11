package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * @author jfernandes
 */
class ListTestCase extends CollectionTestCase {
	
	@Test
	def void listConstructor() {
		'''
		assert.equals([22,2,3], new List(22,2,3))
		'''.test
	}

	@Test
	def void subList() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([22,2], numbers.subList(0,1))
		assert.equals([22,2,10], numbers.subList(0,2))
		assert.equals([2,10], numbers.subList(1,2))
		assert.equals([2], numbers.subList(1,1))
		'''.test
	}
	
	@Test
	def void subListUnhappyPath() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([2,22], numbers.subList(1,0))
		assert.equals([22,2,10], numbers.subList(0,25))
		assert.equals([2,10], numbers.subList(1,2))
		assert.equals([2], numbers.subList(1,1))
		'''.test
	}
	
	@Test
	def void take() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([], numbers.take(-1))
		assert.equals([], numbers.take(0))
		assert.equals([22], numbers.take(1))
		assert.equals([22,2], numbers.take(2))
		assert.equals([22,2,10], numbers.take(3))
		assert.equals([22,2,10], numbers.take(4))
		assert.equals([22,2,10], numbers)
		'''.test
	}
	
	@Test
	def void takeUnhappyPath() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([], [].take(-1))
		assert.equals([], [].take(0))
		assert.equals([], [].take(1))
		assert.equals([], [].take(2))
		'''.test
	}
	
	@Test
	def void drop() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([22,2,10], numbers.drop(-1))
		assert.equals([22,2,10], numbers.drop(0))
		assert.equals([2,10], numbers.drop(1))			
		assert.equals([10], numbers.drop(2))
		assert.equals([], numbers.drop(3))
		assert.equals([], numbers.drop(4))
		assert.equals([22,2,10], numbers)
		'''.test
	}
	
	@Test
	def void dropUnhappyPath() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([], [].drop(-1))
		assert.equals([], [].drop(0))
		assert.equals([], [].drop(1))
		assert.equals([], [].drop(2))
		'''.test
	}	
	
	@Test
	def void reverse() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals([10,2,22], numbers.reverse())
		assert.equals([], [].reverse())
		assert.equals([2], [2].reverse())			
		'''.test
	}
	
	@Test
	def void printingDuplicatedElements(){
		'''
		const l1 = [[3,5,2], [4,2,6]].flatten()
		assert.equals("[3, 5, 2, 4, 2, 6]", l1.toString())


		const l2 = [1,2,3].flatMap({x => [x, x * 2, x * 3]})
		assert.equals("[1, 2, 3, 2, 4, 6, 3, 6, 9]", l2.toString())

		const l3 = [1,1,1]
		assert.equals("[1, 1, 1]", l3.toString())
		'''.test		
	}

	@Test
	def void equalityCaseTrue() {
		'''
		assert.equals(['Hello'], ['Hello'])
		assert.equals([4, 5, 9], [4, 5, 9])
		assert.equals([true], [true])
		assert.equals([], [])
		'''.test		
	}
			
	@Test
	def void equalityCaseFalse() {
		'''
		assert.notEquals(['Hello'], ['Hellou'])
		assert.notEquals([4, 5, 9], [5, 4, 9])
		assert.notEquals([4, 5, 9], [5, 4])
		assert.notThat([4, 5, 9].equals([5, 4]))
		assert.notThat([4, 5, 9].equals([5, 4, 9]))
		assert.notEquals([4, 5, 9], #{4, 5, 9})
		assert.notThat([5, 4].equals([4, 5, 9]))
		assert.notThat([5, 4].equals([5, 4, 9]))
		assert.notThat([5, 4].equals([]))
		assert.notThat([].equals([5, 4]))
		'''.test
	}	

	@Test
	def void withoutDuplicates() {
		'''
		assert.equals([1, 3, 1, 5, 1, 3, 2, 5].withoutDuplicates(), [1, 2, 3, 5])
		assert.equals([1, 3, 5, 2].withoutDuplicates(), [1, 2, 3, 5])
		'''.test
	}	
	
	@Test
	def void sortBy() {
		'''
		«instantiateCollectionAsNumbersVariable»
		numbers.sortBy({a,b=>a>b})
		assert.equals([22,10,2], numbers)
		numbers.sortBy({a,b=>a<b})
		assert.equals([2,10,22], numbers)
		'''.test
	}		

	@Test
	def void getHappyPath() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(22, numbers.get(0))
		'''.test
	}		

	@Test
	def void getUnhappyPath() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.throwsExceptionWithMessage("-1.00000 must be a positive integer value", { numbers.get(-1) })
		'''.test
	}		

	// #1305 vs. #1401 - Infinite loop forces this test to change
	@Test
	def void elementsToString() {
		'''
		object a {
			override method printString() = "es un a"
		}
		
		class B {
			override method printString() = "cierto que era un b!"
		}
		
		program c {
			/*
			assert.throwsExceptionWithMessage(
				"Expected [[es un a]] but found [[cierto que era un b!]]", 
				{ assert.equals([ a ], [ new B() ]) }
			)
			*/
			assert.throwsExceptionWithMessage(
				"Expected [[a[]]] but found [[a B[]]]", 
				{ assert.equals([ a ], [ new B() ]) }
			)
		}
		'''.interpretPropagatingErrors
	}	
	
}
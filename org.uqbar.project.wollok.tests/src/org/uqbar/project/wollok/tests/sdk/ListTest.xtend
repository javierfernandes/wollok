package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.ListTestCase

/**
 * Tests the wollok List class included in the Wollok SDK.
 * 
 * @author jfernandes
 * @author PalumboN
 * @author tesonep
 */
class ListTest extends ListTestCase {
	
	override instantiateCollectionAsNumbersVariable() {
		"const numbers = new List()
		numbers.add(22)
		numbers.add(2)
		numbers.add(10)"
	}
	
	override instantiateStrings() {
		"const strings = new List(); " + System.lineSeparator + " ['hello', 'hola', 'bonjour', 'ciao', 'hi'].forEach{e=> strings.add(e) }"
	}
	
	@Test
	def void toStringOnEmptyCollection() {
		'''
		const numbers = new List()
		assert.equals("[]", numbers.toString())
		'''.test
	}
	
	@Test
	def void identityOnMap() {
		'''
		«instantiateCollectionAsNumbersVariable»
		const strings = numbers.map{e=> e.toString()}
		
		assert.notEquals(numbers.identity(), strings.identity())
		
		assert.that(strings.contains("22"))
		assert.that(strings.contains("2"))
		'''.test
	}
	
	@Test
	def void testContainsWithComplexObjects() {
		'''
		object o1 {}
		object o2 {}
			
		program p {
			const list = [o1, o2]
			
			assert.that(list.contains(o1))
			assert.that(list.contains(o2))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAsListConversion() {
		'''
		const list = [1,2,3]
		assert.equals([1,2,3], list.asList())
		'''.test
	}
	
	@Test
	def void testAsSetConversion() {
		'''
		const set = #{}
		set.add(1)
		set.add(2)
		set.add(3)
		assert.equals(set, set.asSet())
		'''.test
	}
	
	@Test
	def void testListOfNumberAsSetConversion() {
		'''
		assert.equals(3, [1, 2/2, 3, 4, 6/2].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfStringAsSetConversion() {
		'''
		assert.equals(3, ["hola", "chau", "ho" + "la", "c" + "hau", "bye"].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfBooleanAsSetConversion() {
		'''
		assert.equals(2, [true, 1==2, 2==2, 3==4 ].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfDateAsSetConversion() {
		'''
		assert.equals(2, [new Date(day=1, month=4, year=2018),new Date(day=12, month=7, year=2020), 
		new Date(day=1, month=4, year=2018)].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfListAsSetConversion() {
		'''
		var list = [[1,2,3],[5,6],[7,8],[1,2,3],[5,6]]
		assert.equals(3, list.asSet().size())
		'''.test
	}

	@Test
	def void testListOfEmptyListAsSetConversion() {
		'''
		assert.equals(1, [[], []].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfSetAsSetConversion() {
		'''
		var list = [#{1,2,3},#{5,6},#{7,8},#{1,2,3},#{5,6}]
		assert.equals(3, list.asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfEmptySetAsSetConversion() {
		'''
		assert.equals(1, [#{}, #{}].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfEmptyDictionaryAsSetConversion() {
		'''
		assert.equals(1, [new Dictionary(), new Dictionary()].asSet().size())
		'''.test
	}

	@Test
	def void testListOfNonEmptyDictionaryAsSetConversion() {
		'''
		const firstDictionary = new Dictionary()
		firstDictionary.put(1, "hola")
		firstDictionary.put(2, "chau")
		const secondDictionary = new Dictionary()
		secondDictionary.put(1, "hola")
		secondDictionary.put(2, "chau")
		assert.equals(1, [firstDictionary, secondDictionary].asSet().size())
		'''.test
	}
		
	@Test
	def void testListOfPairAsSetConversion() {
		'''
		assert.equals(2, [new Pair(1,2), new Pair(4,5), new Pair(1,2)].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfPositionAsSetConversion() {
		'''
		assert.equals(1, [new Position() ,new Position()].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassAsSetConversionRedefiningEqualEqual() {
		'''
		class Animal {
			override method ==(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
				
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
				
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			assert.equals(2, [new Perro(), new Gato(), new Perro(), new Gato()].asSet().size())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfUserDefinedClassAsSetConversionRedefiningEquals() {
		'''
		class Animal {
			override method ==(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
					
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
					
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			assert.equals(2, [new Perro(), new Gato(), new Perro(), new Gato()].asSet().size())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfNumberWithoutDuplicates() {
		'''
		const list = [1, 3, 1, 5, 1, 3, 2, 5]
		const result = [1, 3, 5, 2]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(4, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i=> assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfStringWithoutDuplicates() {
		'''
		const list = ["amigo", "carpeta", "beca", "amigo", "carpeta"]
		const result = ["amigo", "carpeta", "beca"]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(3, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfDateWithoutDuplicates() {
		'''
		const list = [new Date(day=22, month=9, year=2020), new Date(day=1, month=4, year=2018), new Date(day=22, month=9, year=2020)]
		const result = [new Date(day=22, month=9, year=2020), new Date(day=1, month=4, year=2018)]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfBooleanWithoutDuplicates() {
		'''
		const result = [true, false]
		const withoutDuplicates = [true, false, !false].withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfListWithoutDuplicates() {
		'''
		const lista = new List()
		lista.addAll([1,2,3])
		const list = [[6,7,8,9,22,12], [1,2,3], [1,2,3,4,5], [1,2,3], [6,7,8,9,22,12]]
		const result = [[6,7,8,9,22,12], [1,2,3], [1,2,3,4,5]]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(3, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfEmptyListWithoutDuplicates() {
		'''
		const withoutDuplicates = [[],[]].withoutDuplicates()
		assert.equals(1, withoutDuplicates.size())
		assert.equals([[]], withoutDuplicates)
		'''.test
	}
	
	@Test
	def void testListOfSetWithoutDuplicates() {
		'''
		const set = #{1,2,3}
		const result = [#{1,44,55,33,27,12}, set, #{1,2,3,4,5,6}]
		const list = [#{1,44,55,33,27,12}, set, #{1,2,3,4,5,6}, #{1,2,3}, #{1,2,3,4,5,6}, #{1,44,55,33,27,12}]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(3, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfEmptySetWithoutDuplicates() {
		'''
		const withoutDuplicates = [#{}, #{}].withoutDuplicates()
		assert.equals(1, withoutDuplicates.size())
		assert.equals([#{}], withoutDuplicates)
		'''.test
	}
	
	@Test
	def void testListOfDictionaryWithoutDuplicates() {
		'''
		const dictionary = new Dictionary()
		dictionary.put(1, "hola")
		const result = [dictionary, new Dictionary()]
		const withoutDuplicates = [dictionary, new Dictionary(), dictionary, new Dictionary()].withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfPairWithoutDuplicates() {
		'''
		const result = [new Pair(1,2), new Pair(5,6)]
		const withoutDuplicates = [new Pair(1,2), new Pair(5,6), new Pair(1,2), new Pair(5,6)].withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfPositionWithoutDuplicates() {
		'''
		var position = new Position()
		position = position.up(2)
		const result = [position, new Position()]
		const withoutDuplicates = [position, new Position(), position, new Position()].withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassWithoutDuplicatesRedefiningEqualEqual() {
		'''
		class Animal {
			override method ==(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
			
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
			
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			const list = [new Perro(), new Gato(), new Perro(), new Gato()]
			const result = [new Perro(), new Gato()]
			const withoutDuplicates = list.withoutDuplicates()
			assert.equals(2, withoutDuplicates.size())
			(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfUserDefinedClassWithoutDuplicatesRedefiningEquals() {
		'''
		class Animal {
			override method equals(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
			
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
			
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			const list = [new Perro(), new Gato(), new Perro(), new Gato()]
			const result = [new Perro(), new Gato()]
			const withoutDuplicates = list.withoutDuplicates()
			assert.equals(2, withoutDuplicates.size())
			(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFirstAndHead() {
		'''
		const list = [1,2,3]
		assert.equals(1, list.first())
		assert.equals(1, list.head())
		'''.test
	}

	@Test
	def void testSortBy() {
		''' 
		var list = [1,2,3]
		list.sortBy({x,y => x > y})
		assert.equals([3,2,1], list)
		list.sortBy({x,y => x < y})
		assert.equals([1,2,3], list)
		'''.test
	}
	
	@Test
	def void testSortedBy() {
		'''
		const list = [1,2,3]
		assert.equals([3,2,1], list.sortedBy({x,y => x > y}))
		assert.notThat(list === list.sortedBy({x,y => x < y}))
		'''.test
	}
	
	
	@Test
	def void testEquals() {
		'''
		assert.equals([], [])
		assert.equals([1,2,1], [1,2,1])
		'''.test
	}
	
	@Test
	def void testNotEquals() {
		'''
		assert.notEquals([], [1])
		assert.notEquals([1], [])
		assert.notEquals([1,2], [1])
		assert.notEquals([1,2], [2,1])
		assert.notEquals([1,3], [1,2])
		'''.test
	}
	
	@Test
	def void testEqualityWithOtherObjects(){
		'''
		assert.notEquals(2, [])
		assert.notEquals(2, [2])
		assert.notEquals(2, [2,3,4])
		assert.notEquals(console, [])
		'''.test
	}
}

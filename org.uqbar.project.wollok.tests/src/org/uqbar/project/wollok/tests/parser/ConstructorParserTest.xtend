package org.uqbar.project.wollok.tests.parser


import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

/** 
 * Test representative error messages for constructors
 * @author dodain
 */
class ConstructorParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void constructorsNotAllowedInObjects() {
		'''
		object pepita {
			var energia = 0
			constructor() { }
			method volar() { energia = energia - 20 }
		}
		'''.expectsSyntaxError("Constructors are not allowed in object definition.", false)
	}

	@Test
	def void constructorsNotAllowedInObjects2() {
		'''
		object pepita {
			var energia = 0
			method volar() { energia = energia - 20 }
			constructor() { }
		}
		'''.expectsSyntaxError("Constructors are not allowed in object definition.")
	}

	@Test
	def void constructorsNotAllowedInDescribe() {
		'''
		describe "group of tests" {
			constructor() { }
			test "a simple test" {
				assert.equals(1, 1)
			}
		}
		'''.expectsSyntaxError("Constructors are not allowed in describe definition.")
	} 

	@Test
	def void constructorsNotAllowedInProgram() {
		'''
		program abc {
			const four = 4
			four.even()
			constructor() { }
		}
		'''.expectsSyntaxError("Constructors are not allowed in this definition.")
	} 

	@Test
	def void constructorsNotAllowedInTest() {
		'''
		test "simple test" {
			const four = 4
			assert.equals(4, four)
			constructor() { }
		}
		'''.expectsSyntaxError("Constructors are not allowed in this definition.", false)
	} 

	@Test
	def void constructorsAfterMethodsInClass() {
		'''
		class Ave {
			var energia
			method volar() { energia -= 10 }
			constructor() { 
				energia = 0
			}
		}
		'''.expectsSyntaxError("You should declare constructors before methods.", false)
	} 

}
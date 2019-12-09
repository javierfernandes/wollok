package org.uqbar.project.wollok.tests.parser

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.Test

/** 
 * Test representative error messages for fixtures
 * @author dodain
 */
@Disabled
class FixtureParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void fixtureInObjectAfterMethod() {
		'''
		object pepita {
			var energia = 0
			method volar() { energia = energia - 20 }
			fixture {}
		}
		'''.expectsSyntaxError("Fixture is not allowed in object definition.")
	} 

	@Test
	def void fixtureInObjectBeforeMethod() {
		'''
		object pepita {
			var energia = 0
			fixture {}
			method volar() { energia = energia - 20 }
		}
		'''.expectsSyntaxError("Fixture is not allowed in object definition.", false)
	} 

	@Test
	def void fixtureInClassBeforeMethod() {
		'''
		class Ave {
			var energia = 0
			method volar() { energia = energia - 20 }
			fixture {}
		}
		'''.expectsSyntaxError("Fixture is not allowed in class definition.")
	} 

	@Test
	def void fixtureInClassAfterMethod() {
		'''
		class Ave {
			var energia = 0
			fixture {}
			method volar() { energia = energia - 20 }
		}
		'''.expectsSyntaxError("Fixture is not allowed in class definition.", false)
	} 

	@Test
	def void fixtureInProgram() {
		'''
		program abc {
			const pepita = object {
				method volar() { }
			}
			fixture {}
		}
		'''.expectsSyntaxError("Fixture is not allowed in this definition.", false)
	} 

	@Disabled // it works on IDE but EObject is null when parsing this file
	@Test
	def void fixtureAlone() {
		'''
		fixture {}
		'''.expectsSyntaxError("Fixture is not allowed in this definition.")
	} 

	@Test
	def void fixtureNotAllowedInTest() {
		'''
		test "simple test" {
			const four = 4
			assert.equals(4, four)
			fixture { }
		}
		'''.expectsSyntaxError("Fixture is not allowed in this definition.", false)
	} 

	@Test
	def void fixtureAfterTests() {
		'''
		describe "group of tests" {
			const four
			test "four is four" {
				assert.equals(4, const) 
			}
			fixture {
				four = 4
			}
		}
		'''.expectsSyntaxError("You should declare fixture before tests and methods.", false)
	}

	@Test
	def void fixtureAfterMethods() {
		'''
		describe "group of tests" {
			const four
			method aMethod() { }
			fixture {
				four = 4
			}
			test "four is four" {
				assert.equals(4, const) 
			}
		}
		'''.expectsSyntaxError("You should declare fixture before tests and methods.", false)
	}
	
}
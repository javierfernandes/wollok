package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import static org.uqbar.project.wollok.typesystem.WollokType.*
import org.uqbar.project.wollok.typesystem.StructuralType

/**
 * The most basic inference tests
 * 
 * @author npasserini
 * @author jfernandes
 */
class LiteralsInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void testNumberLiteral() { 	
		''' program { 46 } '''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "46")
		]
	}

	@Test
	def void testStringLiteral() {
		''' program { "Hello" } '''
		.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(STRING), '''"Hello"''')
		]
	}

	@Test
	def void testBooleanLiteral() {
		'''program p { true }'''
		.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(BOOLEAN), "true")
		]
	}
	
	
	@Test
	def void testObjectLiteral() {
		#['''
			program p { object { } }''']
			.parseAndInfer.asserting [
				assertTypeOfAsString("{  }", "object { }")
		]
	}
}
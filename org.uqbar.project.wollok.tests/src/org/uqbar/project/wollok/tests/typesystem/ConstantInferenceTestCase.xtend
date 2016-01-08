package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import wollok.lang.WBoolean
import wollok.lang.WString

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class ConstantInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Test
	def void testNumberLiteral() { 	'''program p {
			val a = 46
			val b = "Hello"
			val c = true
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "val a = 46")
			assertTypeOf(WString, 'val b = "Hello"')
			assertTypeOf(WBoolean, "val c = true")
		]
	}
}
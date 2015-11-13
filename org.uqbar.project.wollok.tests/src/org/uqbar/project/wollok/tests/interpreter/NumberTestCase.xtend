package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author jfernandes
 */
class NumberTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void integersAsResultValueOfNative() {
		'''program a {
			assert.equals(4, "hola".length())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void sum() {
		'''program a {
			assert.equals(4, 3 + 1)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void integersFromNativeObjects() {
		'''program a {
		
			assert.equals(3, "hola".length() - 1)
		
		}
		'''.interpretPropagatingErrors
	}
	
}
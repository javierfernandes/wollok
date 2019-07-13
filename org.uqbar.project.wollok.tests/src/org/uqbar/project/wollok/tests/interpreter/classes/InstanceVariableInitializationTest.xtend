package org.uqbar.project.wollok.tests.interpreter.classes

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests inst var initializations with different values and scenarios
 * 
 * @author jfernandes
 */
class InstanceVariableInitializationTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testNumberInitialization() {
		'''
			class A {
				var i = 10
				var j = 0.10
				
				method getI() = i
				method getJ() = j
			}
			
			program p {
				const a = new A()
				assert.equals(10, a.getI())
				assert.equals(0.10, a.getJ())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCrossReferenceInitialization() {
		'''
			object abc {
				var x = 20
				var y = x * 2
				
				method getY() {
					return y
				}
			}
			program p {
				assert.equals(40, abc.getY())
			}			
		'''.interpretPropagatingErrors
	}
		
	@Test
	def void assignmentToWKODeclared() {
		'''
			object before { method get() = "before" }
			
			class A {
				const b = before
				const a = after 
				
				method getB() = b
				method getA() = a
			}
			
			object after { method get() = "before" }
			
			program p {
				const a = new A()
				assert.equals(before, a.getB())
				assert.equals(after, a.getA())
			}
		'''.interpretPropagatingErrors
	}
	
}
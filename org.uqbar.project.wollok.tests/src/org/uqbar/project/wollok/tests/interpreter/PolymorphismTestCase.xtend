package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests polymorphism in different cases: object literals,
 * classes, etc.
 * 
 * @author jfernandes
 */
class PolymorphismTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testPolymorphicParameterWithObjectLiterals() {
		'''
		program p {
			const pepona = object {
				var energia = 100
				method comer(comida) {
					energia = energia + comida.energia()
				}
				method energia() { 
					return energia
				}
			}

			const alpiste = object {
				method energia() { 
					return 5
				}
			}

			pepona.comer(alpiste)
			
			assert.that(105 == pepona.energia())
		}
		'''.interpretPropagatingErrors
	}
	
}
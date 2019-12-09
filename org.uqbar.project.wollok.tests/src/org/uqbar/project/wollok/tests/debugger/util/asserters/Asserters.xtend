package org.uqbar.project.wollok.tests.debugger.util.asserters

import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.junit.jupiter.api.Assertions

/**
 * Factory methods for DSL like tests
 * 
 * Import it in your tests as import static
 * 
 * @author jfernandes
 */
class Asserters extends Assertions {

	def static InterpreterAsserter noVariables() {
		[ pair |
			val context = pair.value.context
			assertEquals(
				0,
				context.allReferenceNames.length,
				"Expecting no variables but there: " + context.allReferenceNames.map[WVariable it|name].join(', ')
			)
		]
	}

	def static InterpreterAsserter variable(String name, String value) {
		[ state |
			val context = state.value.context
			try {
				// TODO: this is fragile ! It is comparing the variable value by calling its toString() method !
				assertEquals("Expecting variable '" + name + "' to be " + value, value,
					context.resolve(name).toString())
			} catch (UnresolvableReference e) {
				fail(
					'''Expecting variable '«name»' to be «value» But it was not resolvable in the current context: ''' +
						context.allReferenceNames.map[name + '=' + value].join(', '))
			}
		]
	}

}

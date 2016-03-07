package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests for boolean objects and operations
 * 
 * @author jfernandes
 */
class BooleanTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void literals() {
		'''program a {
			assert.that(true)
			assert.notThat(false)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void andWithLiterals() {
		'''program a {
			assert.that(true && true)
			assert.that(true and true)
			
			assert.notThat(true && false)
			assert.notThat(true and false)

			assert.notThat(false && true)
			assert.notThat(false and true)

			assert.notThat(false && false)
			assert.notThat(false and false)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void orWithLiterals() {
		'''program a {
			assert.that(true || true)
			assert.that(true or true)
			
			assert.that(true || false)
			assert.that(true or false)

			assert.that(false || true)
			assert.that(false or true)

			assert.notThat(false || false)
			assert.notThat(false or false)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void andShortcirtuitMustEvaluate() {
		'''
			object p {
				var modified = false
				
				method getModifying() {
					modified = true
					return true
				}
				method getModified() = modified
				method setModified(n) { modified = n }
			}
		program a {
			// evaluated
			assert.that(true && p.getModifying())
			assert.that(p.getModified())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void andShortcircuitMustNOTEvaluate() {
		'''
			object p {
				var modified = false
				
				method getModifying() {
					modified = true
					return true
				}
				method getModified() = modified
			}
		program a {
			assert.notThat(false && p.getModifying())
			assert.notThat(p.getModified())
			
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void orShortcirtuitMustEvaluateSecondPart() {
		'''
			object p {
				var modified = false
				
				method getModifying() {
					modified = true
					return true
				}
				method getModified() = modified
				method setModified(n) { modified = n }
			}
		program a {
			// evaluated
			assert.that(false || p.getModifying())
			assert.that(p.getModified())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void orShortcirtuitMustNOTEvaluateSecondPart() {
		'''
			object p {
				var modified = false
				
				method getModifying() {
					modified = true
					return true
				}
				method getModified() = modified
				method setModified(n) { modified = n }
			}
		test "a" {
			assert.that(true || p.getModifying())
			assert.notThat(p.getModified())
			
		}'''.interpretPropagatingErrors
	}
	
}
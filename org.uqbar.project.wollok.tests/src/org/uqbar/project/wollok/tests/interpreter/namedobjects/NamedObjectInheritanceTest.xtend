package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests named objecst inheriting from a class
 * 
 * @author jfernandes
 */
class NamedObjectInheritanceTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void noExplicitParentMeansObjectSuperclass() {
		'''
			object myObject {
				method something() = "abc"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals(myObject, (myObject->"42").x())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClass() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("1234", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClassWithInstanceVariable() {
		'''
			class MyClass {
				var inheritedVariable = "1234"
			}
			object myObject inherits MyClass {
				method something() {
					return inheritedVariable
				}
				method setInheritedVariable(aValue){
					inheritedVariable = aValue
				}
			}
			
			program p {
				assert.equals("1234", myObject.something())
				myObject.setInheritedVariable("abc")
				assert.equals("abc", myObject.something())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClassAndOverridesMethod() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
				override method myMethod() = "5678"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("5678", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClassAndOverridesMethodCallingSuper() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
				override method myMethod() = super() + "5678"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("12345678", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructor() {
		'''
			class Dog {
				const name
				constructor(param) {
					name = param
				}	
				method name() = name
			}
			object lassie inherits Dog("lassie") {
			}
			
			program p {
				assert.equals("lassie", lassie.name())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructorPassingAnotherWKOAsArgument() {
		'''
			class Dog {
				const owner
				constructor(param) {
					owner = param
				}	
				method owner() = owner
			}
			object lassie inherits Dog(jorge) {
			}
			
			object jorge {
				method name() = "Jorge"
			}
			
			program p {
				assert.equals(jorge, lassie.owner())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructorPassingAnotherWKOMessageReturnValue() {
		'''
			class Dog {
				const owner
				constructor(param) {
					owner = param
				}	
				method owner() = owner
			}
			object lassie inherits Dog(jorge.name()) {
			}
			
			object jorge {
				method name() = "Jorge"
			}
			
			program p {
				assert.equals("Jorge", lassie.owner())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testObjectInheritingFromAClass() {
		'''
		class Auto {
			var property kms
			
			constructor(_kms) {
				kms = _kms
			}
		}
		object bordini inherits Auto(2000) {
			method color() = "celeste"
		}
		program p {
			assert.equals(2000, bordini.kms())
		}'''.interpretPropagatingErrors
	}

	@Test
	def void testObjectInheritingFromAClassNamedParameters() {
		'''
		class Auto {
			var property kms
			var property owner
		}
		object bordini inherits Auto(owner = 'dodain', kms = 2000) {
			method color() = "celeste"
		}
		program p {
			assert.equals(2000, bordini.kms())
		}'''.interpretPropagatingErrors
	}
		
}
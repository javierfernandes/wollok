package org.uqbar.project.wollok.tests.interpreter.clazz

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.interpreter.WollokInterpreterException

/**
 * All tests for construtors functionality in terms of runtime execution.
 * For static validations see the XPECT test.
 * This tests
 * - having multiple constructors
 * - constructor delegation: to this or super
 * - automatic delegation for no-args constructors
 * 
 * @author jfernandes
 */
class ConstructorTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void defaultConstructor() {
		#['''
		class Point {
			var x
			var y
		}
		''',
		'''
		program t {
			val p1 = new Point()
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void singleSimpleConstructor() {
		#['''
		class C {
			var a = 10
			val b
			var c
			
			new(anA, aB, aC) {
				a = anA
				b = aB
				c = aC
			}
			method getA() { return a }
			method getB() { return b }
			method getC() { return c }
		}
		''',
		'''
		program t {
			val c = new C (1,2,3)
			this.assertEquals(1, c.getA())
			this.assertEquals(2, c.getB())
			this.assertEquals(3, c.getC())
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void multipleConstructors() {
		#['''
		class Point {
			var x
			var y
			
			new () { x = 20 ; y = 20 }
			
			new(ax, ay) {
				x = ax
				y = ay
			}
			method getX() { return x }
			method getY() { return y }
		}
		''',
		'''
		program t {
			val p1 = new Point(1,2)
			this.assertEquals(1, p1.getX())
			this.assertEquals(2, p1.getY())

			val p2 = new Point()
			this.assertEquals(20, p2.getX())
			this.assertEquals(20, p2.getY())
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void wrongNumberOfArgsInConstructorCall() {
		try {
			#['''
			class Point {
				var x
				var y
				
				new(ax, ay) { x = ax ; y = ay }
			}
			''',
			'''
			program t {
				val p1 = new Point()
			}
			'''].interpretPropagatingErrorsWithoutStaticChecks
			fail("Should have failed !!")
		}
		catch (WollokInterpreterException e) {
			assertEquals("No constructor in class Point for parameters []", e.cause.cause.cause.message)
		}
	}
	
	@Test
	def void constructorDelegationToThis() {
		#['''
			class Point {
				var x
				var y
				new(ax, ay) { x = ax ; y = ay }
				
				new() = this(10,15) {
				}
				
				method getX() { return x }
				method getY() { return y }
			}
			''',
			'''
			program t {
				val p = new Point()
				this.assertEquals(10, p.getX())
				this.assertEquals(15, p.getY())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void constructorDelegationToThisWithoutBody() {
		#['''
			class Point {
				var x
				var y
				new(ax, ay) { x = ax ; y = ay }
				
				new() = this(10,15)
				
				method getX() { return x }
				method getY() { return y }
			}
			''',
			'''
			program t {
				val p = new Point()
				this.println(p)
				this.assertEquals(10, p.getX())
				this.assertEquals(15, p.getY())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void constructorDelegationToSuper() {
		#['''
			class SuperClass {
				var superX
				new(a) { superX = a }
				
				method getSuperX() { return superX }
			}
			class SubClass extends SuperClass { 
				new(n) = super(n + 1) {}
			}
			''',
			'''
			program t {
				val o = new SubClass(20)
				this.assertEquals(21, o.getSuperX())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void twoLevelsDelegationToSuper() {
		#['''
			class A {
				var x
				new(a) { x = a }
				
				method getX() { return x }
			}
			class B extends A { 
				new(n) = super(n + 1) {}
			}
			class C extends B {
				new(l) = super(l * 2) {}
			}
			''',
			'''
			program t {
				val o = new C(20)
				this.assertEquals(41, o.getX())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void mixedThisAndSuperDelegation() {
		#['''
			class A {
				var x
				var y
				new(p) = this(p.getX(), p.getY()) {}
				new(_x,_y) { x = _x ; y = _y }
				
				method getX() { return x }
				method getY() { return y }
			}
			class B extends A { 
				new(p) = super(p + 10) {}
			}
			class C extends B {
				new(_x, _y) = this(new Point(_x, _y)) {}
				new(p) = super(p) {}
			}
			class Point {
				var x
				var y
				new(_x,_y) { x = _x ; y = _y }
				method +(delta) {
					x += delta
					y += delta
					return this
				}
				method getX() { return x }
				method getY() { return y }
			}
			
			''',
			'''
			program t {
				val o = new C(10, 20)
				this.assertEquals(20, o.getX())
				this.assertEquals(30, o.getY())
			}
			'''].interpretPropagatingErrors
	}
	
	// ***********************
	// ** automatic calls
	// ***********************
	
	@Test
	def void emptyConstructorInSuperClassMustBeAutomaticallyCalled() {
		#['''
			class SuperClass {
				var superX
				new() { superX = 20 }
				
				method getSuperX() { return superX }
			}
			class SubClass extends SuperClass { }
			''',
			'''
			program t {
				val o = new SubClass()
				this.assertEquals(20, o.getSuperX())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void emptyConstructorInSuperClassMustBeAutomaticallyCalledBeforeCallingSubclassEmptyConstructor() {
		#['''
			class SuperClass {
				var superX
				var otherX
				new() { 
					superX = 20
					otherX = 30
				}
				
				method getSuperX() { return superX }
				method getOtherX() { return otherX }
				method setSuperX(a) { superX = a }
			}
			class SubClass extends SuperClass {
				var subX
				new() {
					subX = 10
					this.setSuperX(this.getSuperX() + 20) // 20 + 20
				}
				method getSubX() { return subX }
			}
			''',
			'''
			program t {
				val o = new SubClass()
				this.assertEquals(10, o.getSubX())
				this.assertEquals(40, o.getSuperX())
				this.assertEquals(30, o.getOtherX())
			}
			'''].interpretPropagatingErrors
	}
	
	@Test
	def void emptyConstructorAutoCalledMixingImplicitConstructorInHierarchy() {
		#['''
			class A {
				var x
				new() { x = 20 }
				
				method getX() { return x }
			}
			class B extends A {
			}
			class C extends B {
				var c1
				new() {
					c1 = 10
				}
				method getC1() { return c1 }
			}
			class D extends C {}
			''',
			'''
			program t {
				val o = new D()
				this.assertEquals(20, o.getX())
				this.assertEquals(10, o.getC1())
			}
			'''].interpretPropagatingErrors
	}
	
}
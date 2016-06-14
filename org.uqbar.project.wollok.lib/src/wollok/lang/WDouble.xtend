package wollok.lang

import java.math.BigDecimal
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * @author jfernandes
 */
//TODO: has duplicated code with WInteger
class WDouble extends WNumber<BigDecimal> implements Comparable<WDouble> {
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}
	
	def abs() { this.wrapped.abs.asWollokObject }

	@NativeMessage("+")
	def plus(WollokObject other) { operate(other) [ doPlus(it) ] }
		def dispatch Number doPlus(Integer w) { wrapped + new BigDecimal(w) }
		def dispatch Number doPlus(BigDecimal w) { wrapped + w }
		//TODO: here it should throw a 100% wollok exception class
		def dispatch Number doPlus(Object w) { throw new WollokRuntimeException("Cannot add " + w) }

	@NativeMessage("-")
	def minus(WollokObject other) { operate(other) [ doMinus(it) ] }
		def dispatch Number doMinus(Integer w) { wrapped - new BigDecimal(w) }
		def dispatch Number doMinus(BigDecimal w) { wrapped - w }
		def dispatch Number doMinus(Object w) { throw new WollokRuntimeException("Cannot substract " + w) }

	@NativeMessage("*")
	def multiply(WollokObject other) { operate(other) [ doMultiply(it) ] }
		def dispatch Number doMultiply(Integer w) { wrapped * new BigDecimal(w) }
		def dispatch Number doMultiply(BigDecimal w) { wrapped * w }
		def dispatch Number doMultiply(Object w) { throw new WollokRuntimeException("Cannot multiply " + w) }

	@NativeMessage("/")
	def divide(WollokObject other) { operate(other) [ doDivide(it) ] }
		def dispatch Number doDivide(Integer w) { wrapped / new BigDecimal(w) }
		def dispatch Number doDivide(BigDecimal w) { wrapped / w }
		def dispatch Number doDivide(Object w) { throw new WollokRuntimeException("Cannot divide " + w) }

	@NativeMessage("**")
	def raise(WollokObject other) { operate(other) [ doRaise(it) ] }
		def dispatch Number doRaise(Integer w) { wrapped ** w }
		def dispatch Number doRaise(BigDecimal w) { Math.pow( wrapped.doubleValue , w.doubleValue) }
		def dispatch Number doRaise(Object w) { throw new WollokRuntimeException("Cannot raise " + w) }
	
	@NativeMessage("%")
	def module(WollokObject other) { operate(other) [ doModule(it) ] }
		def dispatch Number doModule(Integer w) { wrapped.remainder(new BigDecimal(w)) }
		def dispatch Number doModule(BigDecimal w) { wrapped.remainder(w) }
		def dispatch Number doModule(Object w) { throw new WollokRuntimeException("Cannot module " + w) }

	@NativeMessage(">")
	def greater(WollokObject other) { wrapped.doubleValue > other.nativeNumber.wrapped.doubleValue }
	@NativeMessage(">=")
	def greaterOrEquals(WollokObject other) { wrapped.doubleValue >= other.nativeNumber.wrapped.doubleValue }
	@NativeMessage("<")
	def lesser(WollokObject other) { wrapped.doubleValue < other.nativeNumber.wrapped.doubleValue }
	@NativeMessage("<=")
	def lesserOrEquals(WollokObject other) { wrapped.doubleValue <= other.nativeNumber.wrapped.doubleValue }

	def invert() { (-wrapped).asWollokObject }
	
	def randomUpTo(WollokObject other) {
		val maximum = other.nativeNumber.wrapped.doubleValue
		val minimum = wrapped.doubleValue()
		((Math.random * (maximum - minimum)) + minimum).doubleValue()
	}
	
	override compareTo(WDouble o) { wrapped.compareTo(o.wrapped) }
	
}
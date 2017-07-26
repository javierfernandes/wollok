package wollok.lang

import java.math.BigDecimal
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * 
 * @author jfernandes
 */
class Range extends AbstractJavaWrapper<IntegerRange> {

	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter) 
	}
	
	def void forEach(WollokObject proc) {
		val c = (proc.getNativeObject(CLOSURE) as Closure)
		initWrapped.forEach[e| c.doApply(e.javaToWollok) ]
	}
	
	def initWrapped() {
		if (wrapped == null) {
			val start = solve("start")
			val end = solve("end")
			val step = solve("step")
			wrapped = new IntegerRange(start, end, step)
		}
		wrapped
	}
	
	def solve(String fieldName) {
		obj.resolve(fieldName).wollokToJava(Integer) as Integer
	}
	
	def Integer validate(Object value) {
		try {
			val castedValue = value.wollokToJava(BigDecimal) as BigDecimal
			if (!castedValue.isInteger) {
				throw new IllegalArgumentException(value.toString() + " : only integers are allowed in a Range")		
			}
		} catch (ClassCastException e) {
			throw new IllegalArgumentException(value.toString() + " : only integers are allowed in a Range")
		}
	}
	
	def anyOne() {
		val wrapped = initWrapped()
		wrapped.toList.random
	}
}
package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import java.util.Collection
import java.util.List
import java.util.Set
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.uqbar.project.wollok.interpreter.stack.VoidObject

/**
 * Holds common extensions for Wollok to Java and Java to Wollok conversions.
 * 
 * @author jfernandes
 */
class WollokJavaConversions {
	
	def static <Input> Procedure1<Input> asProc(WollokClosure proc) { [proc.apply(it as Input)] }
	
	def static <Input, Output> asFun(WollokClosure closure) { [closure.apply(it as Input) as Output] }
	
	def static asInteger(WollokObject it) { ((it as WollokObject).getNativeObject(INTEGER) as JavaWrapper<Integer>).wrapped }
	
	def static isWBoolean(Object it) { it instanceof WollokObject && (it as WollokObject).hasNativeType(BOOLEAN) }
	
	def static isTrue(Object it) { it instanceof WollokObject && ((it as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped }
	
	def static Object wollokToJava(Object o, Class<?> t) {
		if (o == null) return null
		if (t.isInstance(o)) return o

		// acá hace falta diseño. Capaz con un "NativeConversionsProvider" y registrar conversiones.
		if (o instanceof WollokClosure && t == Function1)
			return [Object a | (o as WollokClosure).apply(a)]
		// new conversions
		if (o.isNativeType(INTEGER) && (t == Integer || t == Integer.TYPE)) {
			return ((o as WollokObject).getNativeObject(INTEGER) as JavaWrapper<Integer>).wrapped
		}
		if (o.isNativeType(DOUBLE) && (t == Integer || t == Integer.TYPE)) {
			return ((o as WollokObject).getNativeObject(DOUBLE) as JavaWrapper<Double>).wrapped
		}
		if (o.isNativeType(STRING) && t == String) {
			return ((o as WollokObject).getNativeObject(STRING) as JavaWrapper<String>).wrapped
		}
		if (o.isNativeType(LIST) && (t == Collection || t == List)) {
			return ((o as WollokObject).getNativeObject(LIST) as JavaWrapper<List>).wrapped
		}
		if (o.isNativeType(SET) && (t == Collection || t == Set)) {
			return ((o as WollokObject).getNativeObject(SET) as JavaWrapper<Set>).wrapped
		}
		if (o.isNativeType(BOOLEAN) && (t == Boolean || t == Boolean.TYPE)) {
			return ((o as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped
		}
		
		if (t == Object)
			return o
		if (t.primitive)
			return o	
		
		throw new RuntimeException('''Cannot convert parameter "«o»" of type «o.class.name» to type "«t.simpleName»""''')
	}
	
	def static dispatch isNativeType(Object o, String type) { false }
	def static dispatch isNativeType(Void o, String type) { false }
	def static dispatch isNativeType(WollokObject o, String type) { o.hasNativeType(type) }
	
	def static Object javaToWollok(Object o) {
		if (o == null) return null
		convertJavaToWollok(o)
	}
	
	def static dispatch convertJavaToWollok(Integer o) { evaluator.getOrCreateNumber(o.toString) }
	def static dispatch convertJavaToWollok(Double o) { evaluator.getOrCreateNumber(o.toString) }
	def static dispatch convertJavaToWollok(BigDecimal o) { evaluator.getOrCreateNumber(o.toString) }
	// cache strings ?
	def static dispatch convertJavaToWollok(String o) { evaluator.newInstanceWithWrapped(STRING, o) }
	def static dispatch convertJavaToWollok(Boolean o) { evaluator.booleanValue(o) }
	def static dispatch convertJavaToWollok(List o) { evaluator.newInstanceWithWrapped(LIST, o) }
	def static dispatch convertJavaToWollok(Set o) { evaluator.newInstanceWithWrapped(SET, o) }
	def static dispatch convertJavaToWollok(WollokObject it) { it }
	def static dispatch convertJavaToWollok(VoidObject it) { it } // mmmmmm 
	def static dispatch convertJavaToWollok(Object o) { 
		throw new UnsupportedOperationException('''Unsupported convertion from java «o» («o.class.name») to wollok''')
	}
	
	
	def static getEvaluator() { (WollokInterpreter.getInstance.evaluator as WollokInterpreterEvaluator) }
	
}
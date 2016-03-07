package org.uqbar.project.wollok.interpreter.core

import java.util.Map
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject

/**
 * Contiene metodos "nativos" que están disponibles
 * para todo script como funciones de "this" (aunque solo 
 * a nivel root del archivo. Es decir que estas funciones
 * no están disponibles dentro de un objeto).
 * 
 * @deprecated this is the only "special" evalcontext which is not a WollokObject.
 * That's not happy at all.
 * 
 * @author jfernandes
 */
class WollokNativeLobby extends AbstractWollokDeclarativeNativeObject implements EvaluationContext<WollokObject> {
	static var Map<String, WollokObject> localProgramVariables = newHashMap
	WollokInterpreterConsole console
	
	new(WollokInterpreterConsole console, WollokInterpreter interpreter) {
		super(null, interpreter)
		this.console = console
	}
	
	override getThisObject() { throw new UnsupportedOperationException("Cannot use this in a program's code !")}
	
	override allReferenceNames() {
		localProgramVariables.keySet.map[new WVariable(it, true)]
	}
	
	override resolve(String variableName) throws UnresolvableReference {
		if (localProgramVariables.containsKey(variableName))
			localProgramVariables.get(variableName)
		else if (interpreter.globalVariables.containsKey(variableName))
			interpreter.globalVariables.get(variableName)
		else
			// I18N !
			throw new UnresolvableReference('''Cannot resolve reference «variableName»''')
	}
	
	override setReference(String variableName, WollokObject value) {
		if (!localProgramVariables.containsKey(variableName)){
			if (!interpreter.globalVariables.containsKey(variableName))
				// I18N !
				throw new UnresolvableReference('''Cannot resolve reference «variableName»''')
			else
				interpreter.globalVariables.put(variableName,value)
		}
		else
			localProgramVariables.put(variableName,value)
	}
	
	override addReference(String variable, WollokObject value) {
		localProgramVariables.put(variable, value)
		value
	}
	
	// ******************************
	// ** native
	// ******************************
	
	def println(Object args) {
		console.logMessage("" + args)
	}
	
	def sleep(Integer milis) {
		Thread.sleep(milis)
	}
	
	override addGlobalReference(String name, WollokObject value) {
		interpreter.globalVariables.put(name,value)
		value
	}

}

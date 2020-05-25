package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * A variable within a stack execution.
 * 
 * @author jfernandes
 * @author dodain        Refactored in order to avoid cyclic references
 */
@Accessors
class XDebugStackFrameVariable implements Serializable {
	WVariable variable
	XDebugValue value

	new(WVariable variable, WollokObject value) {
		this.variable = variable
		if (value === null) {
			this.value = null
			return
		}
		this.value = variable.getRemoteValue(value)
	}

	def getRemoteValue(WVariable variable, WollokObject value) {
		val valueIdentifier = value.call("identity").toString
		val allVariableIds = XDebugStackFrame.allVariables.map [ id.toString ]
		if (allVariableIds.contains(valueIdentifier)) {
			return null
		}
		allVariables.add(variable)
		allValues.put(variable, value)
		value.asRemoteValue
	}

	def asRemoteValue(WollokObject object) {
		if (object.hasNativeType(LIST))
			new XWollokListDebugValue(object, LIST)
		else if (object.hasNativeType(SET))
			new XWollokSetDebugValue(object, SET)
		else if (object.hasNativeType(DICTIONARY))
			new XWollokDictionaryDebugValue(object, DICTIONARY)
		else
			new XWollokObjectDebugValue(variable.name, object)
	}

	override equals(Object obj) {
		try {
			val other = obj as XDebugStackFrameVariable
			return other.variable.toString.equals(variable.toString)
		} catch (ClassCastException e) {
			return false
		}
	}

	override hashCode() {
		this.variable.toString.hashCode
	}

	override toString() {
		val valueToString = if (this.value === null) "null" else this.value.toString
		this.variable.toString + " = " + valueToString
	}

	def void collectValues(Map<String, XDebugStackFrameVariable> variableValues) {
		if (this.value !== null) {
			variableValues.put(this.variable.id.toString, this)
			this.value.variables.forEach [ variable | variable.collectValues(variableValues) ]
		}
	}
	
	def isCustom() {
		!this.variable.name.startsWith("wollok.")
	}

	def getIdentifier() {
		this.variable.id.toString
	}

	def getName() {
		this.variable.name
	}

}

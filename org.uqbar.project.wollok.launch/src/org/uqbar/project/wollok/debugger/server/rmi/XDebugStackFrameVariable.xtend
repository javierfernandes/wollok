package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * A variable within a stack execution.
 * 
 * @author jfernandes
 */
@Accessors
class XDebugStackFrameVariable implements Serializable {
	WVariable variable
	XDebugValue value
	
	new(WVariable variable, WollokObject value) {
		this.variable = variable
		this.value = if (value === null) null else value.asRemoteValue
	}
	
	def asRemoteValue(WollokObject object) {
		if (object.hasNativeType(LIST))
			 new XWollokListDebugValue(object, LIST)
		else if (object.hasNativeType(SET))
			 new XWollokListDebugValue(object, SET)
		else
			new XWollokObjectDebugValue(variable.name, object)
	}
	
	override equals(Object obj) {
		try {
			val other = obj as XDebugStackFrameVariable
			return other.variable.name.equals(variable.name)
		} catch (ClassCastException e) {
			return false
		}
	}
	
	override hashCode() {
		this.variable.name.hashCode
	}
	
}
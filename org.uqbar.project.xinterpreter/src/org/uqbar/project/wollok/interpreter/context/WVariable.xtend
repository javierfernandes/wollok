package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */

@Accessors
class WVariable implements Serializable {
	String name
	Integer id
	boolean local
	boolean constant
	
	new(String name, Integer id, boolean local, boolean constant) {
		this.name = name
		this.id = id
		this.local = local
		this.constant = constant
	}
	
	override toString() {
		(this.name ?: "") + (if (id === null) "" else " (" + id + ")" + (if (constant) " - constant" else ""))
	}
	
	override equals(Object obj) {
		try {
			val other = obj as WVariable
			if (other === null || other.id === null) return false
			return other.id.equals(this.id)
		} catch (ClassCastException e) {
			return false
		}
	}
	
	override hashCode() {
		this.id.hashCode
	}
	
}
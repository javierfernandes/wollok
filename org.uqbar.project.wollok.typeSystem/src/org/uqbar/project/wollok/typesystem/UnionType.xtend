package org.uqbar.project.wollok.typesystem

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class UnionType extends BasicType {
	@Accessors(PUBLIC_GETTER)
	List<ConcreteType> types
	
	new(ConcreteType... types) {
		// I will order them by name to have the same expected order, 
		// so it does not matter the order of the types in the textual representation.
		super(types.sortBy[name].join('(', '|', ')', [toString]))
		this.types = types.toList
	}
	
	override getAllMessages() {
		this.types.flatMap [ type | type.allMessages ]
	}
	
}

package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.ClassInstanceType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.StructuralType
import org.uqbar.project.wollok.typesystem.UnionType
import org.uqbar.project.wollok.typesystem.WollokType

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance

class CompatibilityTypes {
	static val basicTypes = newArrayList(NUMBER, BOOLEAN, STRING, DATE, CLOSURE)
	
	static def boolean isBasic(ClassInstanceType type) {
		basicTypes.contains(type.clazz.fqn)
	}

	/** Default behavior: any type is compatible with other */
	static def dispatch boolean isCompatible(WollokType supertype, WollokType subtype) {
		return true
	}

	static def dispatch boolean isCompatible(GenericTypeInstance supertype, GenericTypeInstance subtype) {
		val supertypeParams = supertype.typeParameters.keySet 
		val subtypeParams = subtype.typeParameters.keySet 
		return supertypeParams.length == subtypeParams.length && supertypeParams.containsAll(subtypeParams)
	}
	
	/** Basic type is only compatible with itself */
	static def dispatch boolean isCompatible(ClassInstanceType supertype, ClassInstanceType subtype) {
		return 	(!supertype.isBasic && !subtype.isBasic) || supertype.clazz.name == subtype.clazz.name
	}
	
	static def dispatch boolean isCompatible(UnionType supertype, WollokType subtype) {
		return supertype.types.exists[isCompatible(subtype)]
	}
	
	static def dispatch boolean isCompatible(WollokType supertype, UnionType subtype) {
		return subtype.types.exists[isCompatible(supertype)]
	}

	/** TODO Structural types */
	static def dispatch boolean isCompatible(WollokType supertype, StructuralType subtype) {
		throw new UnsupportedOperationException(Messages.RuntimeTypeSystemException_STRUCTURAL_TYPES_NOT_SUPPORTED)
	}

	/** TODO Structural types */
	static def dispatch boolean isCompatible(StructuralType supertype, WollokType subtype) {
		throw new UnsupportedOperationException(Messages.RuntimeTypeSystemException_STRUCTURAL_TYPES_NOT_SUPPORTED)
	}
}

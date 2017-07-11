package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.Set
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*

/**
 * TODO: Maybe this strategy goes a bit to far unifying variables and we should review it at some point in the future. 
 * Specially, for method parameters, we should take care of prioritizing internal uses over any information from outside the method.
 */
class UnifyVariables extends AbstractInferenceStrategy {
	Set<TypeVariable> alreadySeen = newHashSet

	override analiseVariable(TypeVariable tvar) {
		if (!alreadySeen.contains(tvar)) {
			println('''	Analising unification of «tvar» «tvar.subtypes.size», «tvar.supertypes.size»''')
			var result = Ready

			if (tvar.subtypes.size == 1)
				result = tvar.subtypes.uniqueElement.unifyWith(tvar)
			if (tvar.supertypes.size == 1)
				result = result.join(tvar.unifyWith(tvar.supertypes.uniqueElement))

			if (result != Pending) alreadySeen.add(tvar)
		}
	}

	/**
	 * @return ConcreteTypeState
	 * - Ready means this variable has been analised and needs no further analysis.
	 * - Pending means this variable needs to be visited again.
	 * - Error means a type error was detected, variable will not be visited again.
	 */
	def unifyWith(TypeVariable subtype, TypeVariable supertype) {
		println('''		About to unify «subtype» with «supertype»''')
		if (subtype.unifiedWith(supertype)) {
			println('''		Already unified, nothing to do''')
			return Ready
		}

		// We can only unify in absence of errors, this aims for avoiding error propagation 
		// and further analysis of the (maybe) correct parts of the program.
		if (supertype.hasErrors) {
			println('''		Errors found, aborting unification''')
			return Error
		}

		// If supertype var is a parameter, the subtype is an argument sent to this parameter
		// and should not be unified.
		if (supertype.owner instanceof WParameter) {
			println('''             Not unifying «subtype» with parameter «supertype»''')
			return Error
		}

		// Now we can unify
		subtype.doUnifyWith(supertype) => [
			if (it != Pending)
				println('''		Unified «subtype» with «supertype»: «it»''')
		]
	}

	def dispatch ConcreteTypeState doUnifyWith(TypeVariable subtype, TypeVariable supertype) {
		// We are not handling unification of two variables with no type info, yet it should not be a problem because there is no information to share.
		// Since we are doing nothing, eventually when one of the variables has some type information, unification will be done. 
		if (subtype.typeInfo == null && supertype.typeInfo == null) {
			println('''		No type info yet, unification postponed''')
			Pending
		} else if (subtype.typeInfo == null) {
			subtype.copyTypeInfoFrom(supertype)
		} else if (supertype.typeInfo == null) {
			supertype.copyTypeInfoFrom(subtype)
		} else {
			subtype.typeInfo.doUnifyWith(supertype.typeInfo)
		}
	}

	def copyTypeInfoFrom(TypeVariable v1, TypeVariable v2) {
		try {
			v1.typeInfo = v2.typeInfo
			changed = true
			Ready
		} catch (TypeSystemException typeError) {
			v2.addError(typeError)
			Error
		}
	}

	def dispatch doUnifyWith(SimpleTypeInfo t1, SimpleTypeInfo t2) {
		t1.minTypes = minTypesUnion(t1, t2)
		t1.joinMaxTypes(t2.maximalConcreteTypes)

		t2.users.forEach[typeInfo = t1]

		changed = true
		Ready
	}

	def dispatch doUnifyWith(ClosureTypeInfo t1, ClosureTypeInfo t2) {
		throw new UnsupportedOperationException()
	}

	def dispatch doUnifyWith(VoidTypeInfo t1, VoidTypeInfo t2) {
		// Nothing to do
		Ready
	}

	protected def minTypesUnion(SimpleTypeInfo t1, SimpleTypeInfo t2) {
		(t1.minTypes.keySet + t2.minTypes.keySet).toSet.toInvertedMap [
			if (isReadyIn(t1) && isReadyIn(t2))
				// It was already present and ready in both originating typeInfo's
				Ready
			else
				// Mark this concrete type to be further propagated.
				Pending
		]
	}

	/**
	 * Verify if the received type is already present as a mintype in the variable
	 * and if its Ready (i.e. type information has already been propagated.
	 */
	def boolean isReadyIn(WollokType wollokType, SimpleTypeInfo type) {
		type.minTypes.get(wollokType) == Ready
	}

	def <T> T uniqueElement(Set<T> it) { iterator.next }

}
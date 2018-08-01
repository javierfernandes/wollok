package org.uqbar.project.wollok.typesystem.constraints.types

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfoInContext

/**
 * When a type error is found because we found an incompatible subtype relationship between two type variables, 
 * I am the default strategy to select which of both variables to mark as errored. 
 */
class OffenderSelector {
	static val Logger log = Logger.getLogger(OffenderSelector)

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	def static handleOffense(TypeVariable subtype, TypeVariable supertype, TypeSystemException offense) {
		val offender = selectOffenderVariable(subtype, supertype)
		if (offense.variable === null) offense.variable = offender
		offense.variable = offender
		offense.variable.addError(offense)
	}

	def static selectOffenderVariable(TypeVariable subtype, TypeVariable supertype) {
		val offender = selectOffender(subtype.owner, supertype.owner)
		if(offender == subtype.owner) subtype else supertype
	}

	// ************************************************************************
	// ** Proper offender selection
	// ************************************************************************

	def static dispatch selectOffender(EObject subtype, EObject supertype) {
		log.debug('''
			Min type detected without a specific offender detection strategy:
				subtype=«subtype.debugInfoInContext» 
				supertype=«supertype.debugInfoInContext»
		''')
		subtype
	}

	/**
	 * If one of the variables has no associated node (remember Void parameter type ==> null node), 
	 * we have no alternative but marking the error in the other one.
	 */
	def static dispatch selectOffender(Void subtype, EObject supertype) { supertype }
	def static dispatch selectOffender(EObject subtype, Void supertype) { subtype }

	/**
	 * A variable is subtype of its references.
	 * Error should be marked when the variable is used.
	 */
	def static dispatch selectOffender(WReferenciable referenciable, WVariableReference reference) { reference }

	/** Referenciable appears as supertype when it is assigned, mark the error on the right hand side of the assignment */
	def static dispatch selectOffender(EObject reference, WReferenciable referenciable) { reference }

	/**
	 * A method declaration is subtype of the message sends which invoke that method. 
	 * Errors should go to the sender and not to the method.
	 */
	def static dispatch selectOffender(WMethodDeclaration returnType, EObject messageSend) { messageSend }

	/**
	 * A direct relationship between two parameters is due to a method override.
	 * (note inverse relationship: SUBclass method parameter has to be a SUPERtype of the overriden one.)
	 * We mark the errors in the subclass.
	 */
	def static dispatch selectOffender(WParameter superclass, WParameter subclass) { 
		subclass
	}
	
}

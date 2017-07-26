package org.uqbar.project.wollok.typesystem.constraints

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference


import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.element
import static org.uqbar.project.wollok.sdk.WollokSDK.*

class ConstraintGenerator {
	extension ConstraintBasedTypeSystem typeSystem
	extension TypeVariablesRegistry registry

	val Logger log = Logger.getLogger(this.class)

	OverridingConstraintsGenerator overridingConstraintsGenerator

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
		this.overridingConstraintsGenerator = new OverridingConstraintsGenerator(registry)
	}

	def dispatch void generateVariables(EObject node) {
		// Default case
		log.warn('''WARNING: Not generating constraints for: «node»''')
	}

	def dispatch void generateVariables(WFile it) {
		eContents.forEach[generateVariables]
	}

	def dispatch void generateVariables(WProgram it) {
		elements.forEach[generateVariables]
	}

	def dispatch void generateVariables(WNamedObject it) {
		members.forEach[generateVariables]
		newNamedObject
	}

	def dispatch void generateVariables(WClass it) {
		// TODO Process supertype information: parent and mixins
		members.forEach[generateVariables]
		constructors.forEach[generateVariables]
	}

	def dispatch void generateVariables(WConstructor it) {
		// TODO Process superconstructor information.
		parameters.forEach[generateVariables]
		expression.generateVariables
	}

	def dispatch void generateVariables(WMethodDeclaration it) {
		it.newTypeVariable
		parameters.forEach[generateVariables]

		if (!abstract) {
			expression?.generateVariables
			// Return type for compact methods (others are handled by return expressions)
			if (expressionReturns) beSupertypeOf(expression) else if (tvar.subtypes.empty) beVoid
		}

		if (overrides) overridingConstraintsGenerator.addMethodOverride(it)
	}

	def dispatch void generateVariables(WClosure it) {
		parameters.forEach[generateVariables]
		expression.generateVariables

		newClosure(parameters.map[tvar], expression.tvar)
	}

	def dispatch void generateVariables(WParameter it) {
		newTypeVariable
	}

	def dispatch void generateVariables(WBlockExpression it) {
		expressions.forEach[generateVariables]

		it.newTypeVariable

		if (!expressions.empty) it.beSupertypeOf(expressions.last) else it.beVoid
	}

	def dispatch void generateVariables(WNumberLiteral it) {
		newSealed(classType(NUMBER))
	}

	def dispatch void generateVariables(WStringLiteral it) {
		newSealed(classType(STRING))
	}

	def dispatch void generateVariables(WBooleanLiteral it) {
		newSealed(classType(BOOLEAN))
	}

	def dispatch void generateVariables(WListLiteral it) {
		val listType = newCollection(classType(LIST))
		
		elements.forEach[
			generateVariables
			tvar.beSubtypeOf(listType.element)
		]
	}

	def dispatch void generateVariables(WSetLiteral it) {
		newSealed(classType(SET))
	}

	def dispatch void generateVariables(WConstructorCall it) {
		newSealed(classType(classRef))
	}

	def dispatch void generateVariables(WAssignment it) {
		value.generateVariables
		feature.ref.tvar.beSupertypeOf(value.tvar)

		newVoid
	}

	def dispatch void generateVariables(WVariableReference it) {
		it.newWithSubtype(ref)
	}
	
	def dispatch void generateVariables(WSelf it) {
		it.newSealed(getSelfContext.asWollokType)
	}

	def dispatch void generateVariables(WIfExpression it) {
		condition.generateVariables
		condition.beSealed(classType(BOOLEAN))

		then.generateVariables

		if (getElse != null) {
			getElse.generateVariables

			// If there is a else branch, if can be an expression 
			// and has to be a supertype of both (else, then) branches
			it.newWithSubtype(then, getElse)
		} else {
			// If there is no else branch, if is NOT an expression, 
			// it is a (void) statement.
			newVoid
		}
	}

	def dispatch void generateVariables(WVariableDeclaration it) {
		variable.newTypeVariable()

		if (right != null) {
			right.generateVariables
			variable.beSupertypeOf(right)
		}

		it.newVoid
	}

	def dispatch void generateVariables(WMemberFeatureCall it) {
		memberCallTarget.generateVariables
		memberCallArguments.forEach[generateVariables]

		memberCallTarget.tvar.messageSend(feature, memberCallArguments.map[tvar], it.newTypeVariable)
	}

	def dispatch void generateVariables(WBinaryOperation it) {
		leftOperand.generateVariables
		rightOperand.generateVariables

		leftOperand.tvar.messageSend(feature, newArrayList(rightOperand.tvar), it.newTypeVariable)
	}

	def dispatch void generateVariables(WReturnExpression it) {
		expression.generateVariables
		declaringMethod.beSupertypeOf(expression)
		newVoid
	}

	// ************************************************************************
	// ** Method overriding
	// ************************************************************************
	def addInheritanceConstraints() {
		overridingConstraintsGenerator.run()
	}

	def newNamedObject(WNamedObject it) {
		it.newSealed(it.objectType)
	}

	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	def beSupertypeOf(EObject supertype, EObject subtype) {
		supertype.tvar.beSupertypeOf(subtype.tvar)
	}

	def dispatch WollokType asWollokType(WNamedObject object) {
		objectType(object)
	}

	def dispatch WollokType asWollokType(WClass wClass) {
		classType(wClass)
	}
}

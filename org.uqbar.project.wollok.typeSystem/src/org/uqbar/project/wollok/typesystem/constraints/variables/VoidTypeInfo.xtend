package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.isMultiOpAssignment
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation

class VoidTypeInfo extends TypeInfo {

	// ************************************************************************
	// ** Extension methods
	// ************************************************************************
	
	/** No semantic object means it is a synthetic variable, it might be void in some cases */
	static def dispatch canBeVoid(Void object) { true }
	
	static def dispatch canBeVoid(EObject object) { false }
	static def dispatch canBeVoid(WBlockExpression object) { true }
	static def dispatch canBeVoid(WMethodDeclaration object) { true }
	static def dispatch canBeVoid(WMemberFeatureCall object) { true }
	static def dispatch canBeVoid(WVariableDeclaration object) { true }
	static def dispatch canBeVoid(WReturnExpression object) { true }
	static def dispatch canBeVoid(WPostfixOperation object) { true }
	static def dispatch canBeVoid(WAssignment object) { true }
	static def dispatch canBeVoid(WIfExpression object) { true }
	static def dispatch canBeVoid(WBinaryOperation it) { isMultiOpAssignment }
	
	static def dispatch isVoid(Void typeInfo) { false }
	static def dispatch isVoid(TypeInfo typeInfo) { false }
	static def dispatch isVoid(VoidTypeInfo typeInfo) { true }
	
	// ************************************************************************
	// ** Queries
	// ************************************************************************
	override getType(TypeVariable user) {
		return WollokType.WVoid
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	override fullDescription() '''
		void
	'''

	// ************************************************************************
	// ** Not yet implemented
	// ************************************************************************
	override beSealed() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addMinType(WollokType type) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}

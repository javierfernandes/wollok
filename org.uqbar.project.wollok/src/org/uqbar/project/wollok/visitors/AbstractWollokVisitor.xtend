package org.uqbar.project.wollok.visitors

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WFixture
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Implements an abstract visitor for the AST
 *
 * @author tesonep
 * @author jfernandes
 */
class AbstractWollokVisitor {

	/**
	 * Main method to be used to visit an object.
	 * Allow to interrupt execution if it does not make sense to continue.
	 */
	def doVisit(EObject e) {
		if (shouldContinue(e)) visit(e)
	}
	
	/**
	 * Lets subclasses to decide whether it is necessary to continue with execution.
	 * By default it always visits the whole program tree.
	 */
	def shouldContinue(EObject e) { true }

	/**
	 * Helper method for visiting a collection of EObjects
	 */
	def void visitAll(Iterable<? extends EObject> all) {
		all.forEach[doVisit]
	}

	/**
	 * Avoids NPE if the given object is null.
	 */
	def dispatch void visit(Void it) {}

	def dispatch void visit(WIfExpression it) {
		condition.doVisit
		then.doVisit
		getElse.doVisit
	}

	def dispatch void visit(WTry it) {
		expression.doVisit
		catchBlocks.visitAll
		alwaysExpression.doVisit
	}

	def dispatch void visit(WThrow it) { exception.doVisit }
	def dispatch void visit(WCatch it) { expression.doVisit }

	def dispatch void visit(WAssignment expr) {
		expr.feature.doVisit
		expr.value.doVisit
	}

	def dispatch void visit(WArgumentList args) {
		args.initializers.forEach [ doVisit ]
		args.values.forEach [ doVisit ]
	}
	
	def dispatch void visit(WBinaryOperation it){
		leftOperand.doVisit
		rightOperand.doVisit
	}

	def dispatch void visit(WMemberFeatureCall it){
		memberCallTarget.doVisit
		memberCallArguments.visitAll
	}

	def dispatch void visit(WVariableDeclaration it) {
		variable.doVisit
		right.doVisit
	}

	// i'm not sure why tests fails if we just let the generic WMethodContainer impl for all.
	def dispatch void visit(WMethodContainer it) { eContents.visitAll }

	def dispatch void visit(WMixin it) { eContents.visitAll }
	def dispatch void visit(WSuite it) { eContents.visitAll }
	def dispatch void visit(WClass it) { eContents.visitAll }
	def dispatch void visit(WObjectLiteral it) { eContents.visitAll }
	def dispatch void visit(WNamedObject it) { eContents.visitAll }
	def dispatch void visit(WFixture it) { eContents.visitAll }

	def dispatch void visit(WPackage it) { elements.visitAll }
	def dispatch void visit(WUnaryOperation it) { operand.doVisit }
	def dispatch void visit(WClosure it) { expression.doVisit }
	def dispatch void visit(WConstructor it) { expression.doVisit }
	def dispatch void visit(WMethodDeclaration it) { expression.doVisit }

	def dispatch void visit(WProgram it) { elements.visitAll }
	def dispatch void visit(WTest it) { elements.visitAll }
	def dispatch void visit(WSuperInvocation it) { memberCallArguments.visitAll }
	def dispatch void visit(WConstructorCall it) {	
		argumentList.visit
	}
	
	def dispatch void visit(WCollectionLiteral it) { elements.visitAll }

	def dispatch void visit(WBlockExpression it) { expressions.visitAll	}
	def dispatch void visit(WPostfixOperation it) { operand.doVisit }
	def dispatch void visit(WReturnExpression it) { expression.doVisit }

	// terminal elements
	def dispatch void visit(WVariableReference it) { ref.doVisit }
	def dispatch void visit(WInitializer i) { i.initializer.doVisit }

	// terminals
	def dispatch void visit(WReferenciable ref){}
	def dispatch void visit(WNumberLiteral literal) {}
	def dispatch void visit(WNullLiteral literal) {}
	def dispatch void visit(WStringLiteral literal) {}
	def dispatch void visit(WBooleanLiteral literal) {}
	def dispatch void visit(WParameter param) {}
	def dispatch void visit(WSelf wthis) {}
}

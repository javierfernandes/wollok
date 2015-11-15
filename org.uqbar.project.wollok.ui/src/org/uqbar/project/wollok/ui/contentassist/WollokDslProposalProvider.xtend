package org.uqbar.project.wollok.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.graphics.Image
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WMember

/**
 * 
 * @author jfernandes
 */
class WollokDslProposalProvider extends AbstractWollokDslProposalProvider {
	
	// This whole implementation is just an heuristic until we have a type system
	
	override completeWMemberFeatureCall_Feature(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val call = model as WMemberFeatureCall
		memberProposalsForTarget(call.memberCallTarget, assignment, context, acceptor)

		// still call super for global objects and other stuff
		super.completeWMemberFeatureCall_Feature(model, assignment, context, acceptor)
	}
	
	// default
	def dispatch void memberProposalsForTarget(WExpression expression, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
	}
	
	// to a variable
	def dispatch void memberProposalsForTarget(WVariableReference ref, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		memberProposalsForTarget(ref.ref, assignment, context, acceptor)
	}

	// any referenciable shows all messages that you already sent to it	
	def dispatch void memberProposalsForTarget(WReferenciable ref, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		ref.allMessageSent.filter[feature != null].forEach[ context.addProposal(it, acceptor) ]
	}
	
	// message to WKO's (shows the object's methods)
	def dispatch void memberProposalsForTarget(WNamedObject ref, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		ref.allMethods.forEach[ context.addProposal(it, acceptor) ]
	}
	
	// messages to this
	def dispatch void memberProposalsForTarget(WSelf dis, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		dis.declaringContext.allMethods.forEach[ context.addProposal(it, acceptor) ]
	}
	
	// *****************************
	// ** proposing methods and how they are completed
	// *****************************
	
	def addProposal(ContentAssistContext context, WMember m, ICompletionProposalAcceptor acceptor) {
		acceptor.addProposal(context, m.asProposal, WollokActivator.getInstance.getImageDescriptor('icons/wollok-icon-method_16.png').createImage)
	}
	
	def dispatch asProposal(WMemberFeatureCall call) {
		call.feature + "(" + call.memberCallArguments.map[asProposalParameter].join(",") + ")"
	}
	
	def dispatch asProposal(WMethodDeclaration it) {
		name + "(" + parameters.map[p| p.name ].join(", ") + ")" 
	}
	
	def dispatch asProposalParameter(WVariableReference r) {  r.ref.name }
	def dispatch asProposalParameter(WClosure c) { '''[«c.parameters.map[":" + name].join(" ")»| ]''' }
	def dispatch asProposalParameter(WBooleanLiteral c) { "aBoolean" }
	def dispatch asProposalParameter(WNumberLiteral c) { "aNumber" }
	def dispatch asProposalParameter(WStringLiteral c) { "aString" }
	def dispatch asProposalParameter(WCollectionLiteral c) { "aCollection" }
	def dispatch asProposalParameter(WObjectLiteral c) { "anObject" }
	def dispatch asProposalParameter(WNullLiteral c) { "null" } //mmm
	def dispatch asProposalParameter(WSelf c) { "this" } //mmm
	def dispatch asProposalParameter(WExpression r) { "something" }

	// *****************************
	// ** generic extension methods
	// *****************************	
	
	def createProposal(ContentAssistContext context, String methodName, Image image) {
		createCompletionProposal(methodName, methodName, image, context)
	}
	
	def addProposal(ICompletionProposalAcceptor acceptor, ContentAssistContext context, String feature, Image image) {
		if (feature != null) acceptor.accept(context.createProposal(feature, image))
	}
	
		//@Inject
  	//protected WollokDslTypeSystem system

//	def dispatch void memberProposalsForTarget(WVariableReference reference, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
//		super.completeWMemberFeatureCall_Feature(reference, assignment, context, acceptor)
		// TYPE SYSTEM
		// TODO: Hacer un extension point
		//		reference.ref.type.allMessages.forEach[m| if (m != null) acceptor.addProposal(context, m.asProposal, WollokActivator.getInstance.getImageDescriptor('icons/wollok-icon-method_16.png').createImage)]
		//			reference.ref.messagesSentTo.forEach[m| acceptor.addProposal(context, m.asProposalText, m.image)]
//	}
/* 
	def asProposal(MessageType message) {
		message.name + "(" + message?.parameterTypes.map[p| p.asParamName ].join(", ") + ")" 
	}
	
	def dispatch String asParamName(WollokType type) { type.name }
	def dispatch String asParamName(StructuralType type) { "anObj" }
	def dispatch String asParamName(ObjectLiteralWollokType type) { "anObj" }
	
	def type(WReferenciable r) {
		val env = system.emptyEnvironment()
		val e = r.eResource.contents.filter(WFile).head.body
		system.inferTypes(env, e)
		system.queryTypeFor(env, r).first
	}
*/	

}

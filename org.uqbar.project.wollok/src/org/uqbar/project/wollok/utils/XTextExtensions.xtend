package org.uqbar.project.wollok.utils

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.ITextRegionWithLineInformation
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WTest

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Extension methods and utilities for xtext
 * 
 * @author jfernandes
 */
class XTextExtensions {
	// Esto deberia estar en las extensiones de debugging creo.
	public static val String LINE_NUMBER_SEPARATOR = "|"
	
	def static toSourceCodeLocation(EObject o) {
		o.astNode.textRegionWithLineInformation.toSourceCodeLocation(o.fileURI) => [ contextDescription = o.contextDescription ]
	}
	
	def static dispatch String contextDescription(Void o) { null }
	def static dispatch String contextDescription(EObject o) { /*println("No context for " + o) ;*/ null }
	def static dispatch String contextDescription(WExpression e) { e.method.contextDescription }
	def static dispatch String contextDescription(WMethodDeclaration m) {
		m.declaringContext.contextName + "." + m.name + "(" + m.parameters.map[name].join(",") + ")"
	}
	
	def static toSourceCodeLocation(ITextRegionWithLineInformation t, URI file) {
		new SourceCodeLocation(file, t.lineNumber, t.endLineNumber, t.offset, t.length)
	}
	
	def static astNode(EObject o) { 
		val node = NodeModelUtils.findActualNodeFor(o)
		if (node === null)
			throw new WollokRuntimeException("Could NOT find AST Node for EObject " + o)
		node
	}
	def static fileURI(EObject o) { o.eResource.URI }
	def static lineNumber(EObject o) { o.astNode.startLine }
	def static sourceCode(EObject o) { o.astNode.text }
	def static shortSourceCode(EObject o) { o.sourceCode.trim.replaceAll(System.lineSeparator, ' ') }
	
	def static objectURI(EObject o) { (o.eResource as XtextResource).getURIFragment(o) }
	
	def static getSiblings(EObject o) { o.eContainer.eContents.filter[it != o] }
	
	def static getSiblings(WTest t) {
		try {
			(t.eContainer as WFile).tests	
		} catch (ClassCastException e) {
			(t.eContainer as WSuite).tests
		}
		
	}
	
	def static allSiblingsBefore(EObject o) {
		val beforeNodes = newArrayList
		for (c : o.eContainer.eContents) {
			if (c != o)
				beforeNodes.add(c)
			else
				return beforeNodes
		}
	}
	
	def static WExpression nextExpression(EObject o) {
		val position = o.eContainer.eContents.indexOf(o)
		if (position === -1 || position === o.eContainer.eContents.length - 1) return null
		return o.eContainer.eContents.get(position + 1) as WExpression  
	}	

	def static computeUnusedUri(XtextResourceSet resourceSet, String name) {
		var i = 0
		while(i < Integer.MAX_VALUE) {
			val syntheticUri = URI.createURI(name + i + "." + WollokConstants.PROGRAM_EXTENSION);
			if (resourceSet.getResource(syntheticUri, false) === null)
				return syntheticUri
			i++
		}
		throw new IllegalStateException
	}
	
}
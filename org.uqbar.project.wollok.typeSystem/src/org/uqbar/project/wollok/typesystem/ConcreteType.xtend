package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * A WollokType that is "tangible".
 * That is, it's backed up by a construction created by the user
 * which has methods implementing messages.
 * 
 * It's not a type system invention abstracted based on a variables usage, like
 * structural types.
 * 
 * @author jfernandes
 */
interface ConcreteType extends WollokType {

	def WMethodDeclaration lookupMethod(MessageType message)
	
}
package org.uqbar.project.wollok.typesystem

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.allMethods
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.methods

/**
 * 
 * @author jfernandes
 */
class ObjectLiteralType extends BasicType implements ConcreteType {
	WObjectLiteral object

	@Accessors(PUBLIC_GETTER)
	TypeSystem typeSystem
	
	new(WObjectLiteral obj, TypeSystem typeSystem) {
		super("<object>")
		object = obj
		this.typeSystem = typeSystem
	}
	
	override getName() { '{ ' + object.methods.map[name].join(' ; ') + ' }'	}

	override getContainer() { object }
	
	def signature(WMethodDeclaration m) {
		m.name + parametersSignature(m) + returnTypeSignature(m)
	}
	
	def parametersSignature(WMethodDeclaration m) {
		if (m.parameters.empty) 
			"" 
		else 
			"(" + m.parameters.map[type.name].join(", ") + ')'
	}
	
	def returnTypeSignature(WMethodDeclaration m) {
		val rType = typeSystem.type(m)
		if (rType == WollokType.WVoid)
			''
		else
		 	' : ' + rType
	}
	
	override understandsMessage(MessageType message) {
		lookupMethod(message) !== null
	}
	
	override lookupMethod(MessageType message) {
		lookupMethod(message.name, message.parameterTypes)		
	}
	
	override lookupMethod(String selector, List<?> parameterTypes) {
		val m = object.lookupMethod(selector, parameterTypes, true)
		// TODO: por ahora solo checkea misma cantidad de parametros
		// 		debería en realidad checkear tipos !  
		if (m !== null)
			m
		else
			null
	}
	
	override resolveReturnType(MessageType message) {
		val method = lookupMethod(message)
		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir
		typeSystem.type(method)
	}
	
	override getAllMessages() { object.allMethods.map[messageType] }
	
	override dispatch refine(WollokType previous) {
		val intersectMessages = allMessages.filter[previous.understandsMessage(it)]
		new StructuralType(intersectMessages.iterator)
	}
	
	def messageType(WMethodDeclaration m) { typeSystem.queryMessageTypeForMethod(m) }
	def type(WParameter p) { typeSystem.type(p) }
}
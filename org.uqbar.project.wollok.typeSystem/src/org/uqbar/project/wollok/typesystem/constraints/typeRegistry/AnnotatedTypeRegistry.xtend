package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	EObject context

	new(TypeVariablesRegistry registry, EObject context) {
		this.registry = registry
		this.context = context
	}

	override addTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] paramTypes, TypeAnnotation returnType) {
		val method = receiver.lookupMethod(selector, paramTypes)
		method.parameters.biForEach(paramTypes)[parameter, type|beSealed(parameter,type)]
		method.beSealed(returnType)
	}
	
	def dispatch beSealed(EObject object, SimpleTypeAnnotation<?> annotation) {
		registry.newSealed(object, annotation.type)
	}

	def dispatch beSealed(EObject object, ClassParameterTypeAnnotation annotation) {
		registry.newClassParameterVar(object, annotation.paramName)
	}
}

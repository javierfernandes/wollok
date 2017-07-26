package org.uqbar.project.wollok.typesystem.annotations

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeProvider
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo

import static org.uqbar.project.wollok.sdk.WollokSDK.*

abstract class TypeDeclarations {
	TypeDeclarationTarget target
	TypeProvider types
	EObject context

	static def addTypeDeclarations(TypeDeclarationTarget target, TypeProvider provider,
		Class<? extends TypeDeclarations> declarations, EObject context) {
		declarations.newInstance => [
			it.target = target
			it.types = provider
			it.context = context
			it.declarations()
		]
	}

	def void declarations()

	// ****************************************************************************
	// ** General syntax
	// ****************************************************************************
	def operator_doubleGreaterThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, String selector) {
		new MethodIdentifier(target, receiver.type, selector)
	}

	def operator_doubleArrow(List<? extends TypeAnnotation> parameterTypes, TypeAnnotation returnType) {
		new MethodTypeDeclaration(parameterTypes, returnType)
	}

	// ****************************************************************************
	// ** Synthetic operator syntax
	// ****************************************************************************
	def operator_plus(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "+", #[parameterType])
	}

	def operator_minus(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "-", #[parameterType])
	}

	def operator_multiply(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "*", #[parameterType])
	}

	def operator_greaterThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, ">", #[parameterType])
	}


	// ****************************************************************************
	// ** Core class and object types
	// ****************************************************************************
	def Void() { new VoidTypeAnnotation() }

	def Any() { new SimpleTypeAnnotation(WollokType.WAny) }

	def Boolean() { classTypeAnnotation(BOOLEAN) }
	
	def Number() { classTypeAnnotation(NUMBER) }

	def String() { classTypeAnnotation(STRING) }

	def Date() { classTypeAnnotation(DATE) }

	def List() { classTypeAnnotation(LIST) }

	def Set() { classTypeAnnotation(SET) }

	def Collection() { classTypeAnnotation(COLLECTION) }

	def Range() { classTypeAnnotation(RANGE) }

	def console() { objectTypeAnnotation(CONSOLE) }

	def ELEMENT() { new ClassParameterTypeAnnotation(GenericTypeInfo.ELEMENT) }

	def classTypeAnnotation(String classFQN) { new SimpleTypeAnnotation(types.classType(context, classFQN)) }

	def objectTypeAnnotation(String objectFQN) { new SimpleTypeAnnotation(types.objectType(context, objectFQN)) }
	
	def closure(List<TypeAnnotation> parameters, TypeAnnotation returnType) {
		new ClosureTypeAnnotation(parameters, returnType)
	}
}

// ****************************************************************************
// ** DSL utility classes
// ****************************************************************************
class ExpectReturnType {

	TypeDeclarationTarget target

	ConcreteType receiver

	String selector

	List<TypeAnnotation> parameterTypes

	new(TypeDeclarationTarget target, ConcreteType receiver, String selector, List<TypeAnnotation> parameterTypes) {
		this.target = target
		this.receiver = receiver
		this.selector = selector
		this.parameterTypes = parameterTypes

	}

	def operator_doubleArrow(TypeAnnotation returnType) {
		target.addTypeDeclaration(receiver, selector, parameterTypes, returnType)
	}
}

class MethodIdentifier {
	TypeDeclarationTarget target
	ConcreteType receiver
	String selector

	new(TypeDeclarationTarget target, ConcreteType receiver, String selector) {
		this.target = target
		this.receiver = receiver
		this.selector = selector
	}

	def operator_tripleEquals(MethodTypeDeclaration methodType) {
		target.addTypeDeclaration(receiver, selector, methodType.parameterTypes, methodType.returnType)
	}
}

class MethodTypeDeclaration {
	@Accessors
	List<? extends TypeAnnotation> parameterTypes

	@Accessors
	TypeAnnotation returnType

	new(List<? extends TypeAnnotation> parameterTypes, TypeAnnotation returnType) {
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}

}

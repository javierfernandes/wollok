package org.uqbar.project.wollok.model

import java.util.Arrays
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WLibrary
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThisDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * Extension methods for WMethodContainers.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WMethodContainerExtensions extends WollokModelExtensions {
	
	def static namedObjects(WPackage p){p.elements.filter(WNamedObject)}
	def static namedObjects(WLibrary p){p.elements.filter(WNamedObject)}

	def static boolean isAbstract(WClass it) { hasUnimplementedInheritedMethods }
	def static boolean isAbstract(WMethodDeclaration it) { expression == null && !native }

	def static hasUnimplementedInheritedMethods(WClass c) {
		val unimplementedMethods = <WMethodDeclaration>newArrayList
		c.superClassesIncludingYourselfTopDownDo [ claz |
			unimplementedMethods.removeAllSuchAs[claz.overrides(name)]
			unimplementedMethods.addAll(claz.abstractMethods);
		]
		!unimplementedMethods.empty
	}

	def static boolean isNative(WMethodContainer it) { methods.exists[m|m.native] }
	
	def static methods(WMethodContainer c) { c.members.filter(WMethodDeclaration) }
	def static abstractMethods(WClass it) { methods.filter[isAbstract] }
	def static overrideMethods(WClass it) { methods.filter[overrides].toList }
	def static boolean overrides(WClass c, String methodName) { c.overrideMethods.exists[name == methodName] }
	
	def static declaringMethod(WParameter p) { p.eContainer as WMethodDeclaration }
	def static overridenMethod(WMethodDeclaration m) { m.declaringContext.parent.lookupMethod(m.name) }
	def static superMethod(WSuperInvocation sup) { sup.method.overridenMethod }
	
	def static variableDeclarations(WMethodContainer c) { c.members.filter(WVariableDeclaration) }

	def static variables(WMethodContainer c) { c.variableDeclarations.variables }
	def static variables(WProgram p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(WTest p) { p.elements.filter(WVariableDeclaration).variables }
	def static variables(Iterable<WVariableDeclaration> declarations) { declarations.map[variable] }
	
	def static dispatch allMethods(WNamedObject o) { o.methods }
	def static dispatch allMethods(WObjectLiteral o) { o.methods }
	def static dispatch allMethods(WClass c) {
		val methods = newArrayList
		c.superClassesIncludingYourselfTopDownDo[cl |
			// remove overriden
			cl.overrideMethods.forEach[methods.remove(it.overridenMethod)]
			// add all
			methods.addAll(cl.methods)
		]
		methods
	}

	def static actuallyOverrides(WMethodDeclaration m) {
		m.declaringContext != null && inheritsMethod(m.declaringContext, m.name)
	}

		
	def static dispatch WClass parent(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch WClass parent(WClass c) { c.parent }
	def static dispatch WClass parent(WObjectLiteral c) { null } // For now, object literals do not allow superclasses
	def static dispatch WClass parent(WNamedObject c) { null } // For now, object literals do not allow superclasses

	def static dispatch members(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen")  }
	def static dispatch members(WClass c) { c.members }
	def static dispatch members(WObjectLiteral c) { c.members }
	def static dispatch members(WNamedObject c) { c.members }
	
	def static dispatch contextName(WMethodContainer c) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch contextName(WClass c) { c.fqn }
	def static dispatch contextName(WObjectLiteral c) { "<anonymousObject>" }
	def static dispatch contextName(WNamedObject c) { c.fqn }
	
	def static dispatch boolean inheritsMethod(WMethodContainer c, String name) { throw new UnsupportedOperationException("shouldn't happen") }
	def static dispatch boolean inheritsMethod(WClass c, String name) { c.parent != null && c.parent.hasOrInheritMethod(name) }
	def static dispatch boolean inheritsMethod(WObjectLiteral c, String name) { false }
	def static dispatch boolean inheritsMethod(WNamedObject c, String name) { false }
	
	def static boolean hasOrInheritMethod(WClass c, String mname) { 
		c != null && (c.methods.exists[name == mname] || c.parent.hasOrInheritMethod(mname))
	}

	def static WMethodDeclaration lookupMethod(WMethodContainer behavior, String message) { 
		val method = behavior.methods.findFirst[name == message]
		
		if (method != null) 
			return method
		else if (behavior.parent != null)
			behavior.parent.lookupMethod(message)
		else 
			null
	}

	def static dispatch boolean isValidCall(WClass c, WMemberFeatureCall call) {
		c.methods.exists[isValidMessage(call)] || (c.parent != null && c.parent.isValidCall(call))
	}

	def static dispatch boolean isValidCall(WObjectLiteral c, WMemberFeatureCall call) {
		c.methods.exists[isValidMessage(call)]
	}

	def static dispatch boolean isValidCall(WNamedObject c, WMemberFeatureCall call) {
		c.methods.exists[isValidMessage(call)]
	}


	// ************************************************************************
	// ** Basic methods
	// ************************************************************************

	def static void superClassesIncludingYourselfTopDownDo(WClass cl, (WClass)=>void action) {
		if (cl.parent != null) cl.parent.superClassesIncludingYourselfTopDownDo(action)
		action.apply(cl)
	}
	
	def static <R> R foldUp(WClass cl, R initialValue, (R, WClass)=>R action) {
		val nextValue = action.apply(initialValue, cl)
		if (cl.parent != null) 
			cl.parent.foldUp(nextValue, action)
		else 
			nextValue 
	}
	
	// ** native **
	
	def static Object createNativeObject(WClass it, WollokObject obj, WollokInterpreter interpreter) {
		val javaClass = Class.forName(fqn)
		try
			javaClass.getConstructor(WollokObject, WollokInterpreter).newInstance(obj, interpreter)
		catch (NoSuchMethodException e)
			javaClass.newInstance
	}

	def static Object createNativeObject(WNamedObject it, WollokObject obj, WollokInterpreter interpreter) {
		var className = fqn
		var classNameParts = className.split("\\.")
		val lastPosition = classNameParts.length - 1
		classNameParts.set(lastPosition, classNameParts.get(lastPosition).toFirstUpper)
		
		className = classNameParts.join(".")
		
		val javaClass = Class.forName( className + "Object")
		try
			javaClass.getConstructor(WollokObject, WollokInterpreter).newInstance(obj, interpreter)
		catch (NoSuchMethodException e)
			javaClass.newInstance
	}

	def static dispatch feature(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }
	def static dispatch feature(WMemberFeatureCall call) { call.feature }
	def static dispatch feature(WSuperInvocation call) { call.method.name }

	// TODO Esto no debería ser necesario pero no logro generar bien la herencia entre estas clases para poder tratarlas polimórficamente.
	def static dispatch memberCallArguments(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }
	def static dispatch memberCallArguments(WMemberFeatureCall call) { call.memberCallArguments }
	def static dispatch memberCallArguments(WSuperInvocation call) { call.memberCallArguments }
	
	// ************************************************************************
	// ** isKindOf(c1, c2): Tells whether c1 is a type or subtype of c2
	// ** TODO: think if this can be a
	// ************************************************************************	

	def static dispatch isKindOf(WMethodContainer c1, WMethodContainer c2) { c1 == c2 }
	def static dispatch isKindOf(WClass c1, WClass c2) { WollokModelExtensions.isSuperTypeOf(c2, c1) }
	
	def static dispatch WConstructor resolveConstructor(WClass clazz, Object[] arguments) {
		if (arguments.size == 0 && (clazz.constructors == null || clazz.constructors.empty))
			// default constructor
			clazz.findConstructorInSuper(arguments)
		else {
			val c = clazz.constructors.findFirst[ parameters.size == arguments.size ]
			if (c == null)
				throw new WollokRuntimeException('''No constructor in class «clazz.name» for parameters «Arrays.toString(arguments)»''');
			c
		}
	} 
	def static dispatch WConstructor resolveConstructor(WMethodContainer otherContainer, Object... arguments) {
		throw new WollokRuntimeException('''Impossibel to call a constructor on anything besides a class''');
	}
	
	// ************************************************************************
	// ** Constructors delegation, etc.
	// ************************************************************************
	
	def static dispatch resolveConstructorReference(WMethodContainer behave, WThisDelegatingConstructorCall call) { behave.resolveConstructor(call.arguments) }
	def static dispatch resolveConstructorReference(WMethodContainer behave, WSuperDelegatingConstructorCall call) { findConstructorInSuper(behave, call.arguments) }
	
	def static findConstructorInSuper(WMethodContainer behave, Object[] args) {
		(behave as WClass).parent?.resolveConstructor(args)
	}
}
package org.uqbar.project.wollok.interpreter.core

import java.util.Collections
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.common.util.ECollections
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.AbstractWollokCallable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.natives.DefaultNativeObjectFactory
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*

import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * A wollok user defined (dynamic) object.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokObject extends AbstractWollokCallable implements EvaluationContext<WollokObject> {
	public static val SELF_VAR = new WVariable(SELF, null, false, false)

	@Accessors(PUBLIC_GETTER) val Map<String, WollokObject> instanceVariables = newHashMap
	@Accessors(PUBLIC_GETTER) val List<String> constantReferences = newArrayList
	@Accessors(PUBLIC_GETTER) val Map<WMethodContainer, Object> nativeObjects = newHashMap
	val EvaluationContext<WollokObject> parentContext
	List<String> properties = newArrayList
	List<String> constantsProperties = newArrayList

	new(IWollokInterpreter interpreter, WMethodContainer behavior) {
		super(interpreter, behavior)
		parentContext = interpreter.currentContext
	}

	override getReceiver() { this }

	def dispatch void addMember(WMethodDeclaration method) { /** Nothing to do */ }

	def dispatch void addMember(WVariableDeclaration declaration) {
		declaration.addMember(true)
	}

	def void addMember(WVariableDeclaration declaration, boolean initializeIt) {
		val variableName = declaration.variable.name
		instanceVariables.put(variableName, interpreter.performOnStack(declaration, this) [|
			if (initializeIt) declaration.right?.eval else null
		])
		if (!declaration.writeable) {
			constantReferences.add(variableName)
		}
		if (declaration.property) {
			properties.add(variableName)
			if (!declaration.writeable) {
				constantsProperties.add(variableName)
			}
		}
	}

	// ******************************************
	// **
	// ******************************************
	override getThisObject() { this }

	override call(String message, WollokObject... parameters) {
		val method = behavior.lookupMethod(message, parameters, false)
		if (method === null) {
			if (message.hasProperty) {
				return resolveProperty(message, parameters)
			} else {
				throwMessageNotUnderstood(message, parameters)
			}
		}
		method.call(parameters)
	}

	def resolveProperty(String message, WollokObject[] parameters) {
		if (parameters.empty) {
			return resolve(message)
		}
		if (parameters.size > 1) {
			throwMessageNotUnderstood(message, parameters)
		}
		if (constantsProperties.contains(message)) {
			throw messageNotUnderstood(NLS.bind(Messages.WollokDslValidator_PROPERTY_NOT_WRITABLE, message))
		}
		setReference(message, parameters.head)
		return theVoid
	}

	override hasProperty(String variableName) {
		properties.contains(variableName)
	}

	def throwMessageNotUnderstood(String methodName, Object... parameters) {
		try {
			call("messageNotUnderstood", methodName.javaToWollok, parameters.map[javaToWollok].javaToWollok)
		} catch (WollokProgramExceptionWrapper e) {
			// this one is ok because calling messageNotUnderstood actually throws the exception!
			throw e
		} catch (RuntimeException e) {
			throw new RuntimeException(NLS.bind(Messages.WollokInterpreter_errorWhileMessageNotUnderstood, e.message), e)
		}
	}

	// ahh repetido ! no son polimorficos metodos y constructores! :S
	def invokeConstructor(WollokObject... objects) {
		behavior.resolveConstructor(objects)?.evaluateConstructor(objects)
	}

	def void evaluateConstructor(WConstructor constructor, WollokObject[] objects) {
		val constructorEvalContext = constructor.createEvaluationContext(objects)
		// delegation
		val other = constructor.delegatingConstructorCall
		if (other !== null) {
			val delegatedConstructor = constructor.wollokClass.resolveConstructorReference(other)
			var EList<? extends EObject> arguments = ECollections.emptyEList
			if (other.hasNamedParameters) {
				arguments = ECollections.asEList(delegatedConstructor.parameters.map [ name ].map [ 
					argName | other.argumentList.getArgument(argName)					
				])
			} else {
				arguments = other.arguments
			}
			delegatedConstructor?.invokeOnContext(other, arguments, constructorEvalContext) // no 'this' as parent context !
		} else {
			// automatic super() call
			val delegatedConstructor = constructor.wollokClass.findConstructorInSuper(EMPTY_OBJECTS_ARRAY)
			delegatedConstructor?.invokeOnContext(constructor, Collections.EMPTY_LIST, constructorEvalContext)
		}

		// actual call
		if (constructor.expression !== null) {
			val context = then(constructorEvalContext, this)
			interpreter.performOnStack(constructor, context)[|interpreter.eval(constructor.expression)]
		}
	}

	def invokeOnContext(WConstructor constructor, EObject call, List<? extends EObject> argumentsToEval,
		EvaluationContext<WollokObject> context) {
		interpreter.performOnStack(call, context) [|
			evaluateConstructor(constructor, argumentsToEval.evalAll)
			null
		]
	}

	def createEvaluationContext(WConstructor declaration, WollokObject... values) {
		asEvaluationContext(declaration.parameters.createMap(values))
	}

	override resolve(String variableName) {
		if (variableName == SELF)
			this
		else if (instanceVariables.containsKey(variableName)) {
			instanceVariables.get(variableName)
		}
		else
			parentContext.resolve(variableName)
	}

	override setReference(String name, WollokObject value) {
		if (name == SELF)
 			throw new RuntimeException(NLS.bind(Messages.WollokDslValidator_CANNOT_MODIFY_REFERENCE, SELF))
		if (!instanceVariables.containsKey(name)) {
			throw new UnresolvableReference('''Unrecognized variable "«name»" in object "«this.behavior.objectDescription»"''')
		}

		val oldValue = instanceVariables.put(name, value)
		listeners.forEach[fieldChanged(name, oldValue, value)]
	}

	// query (kind of reflection api)
	override allReferenceNames() {
		instanceVariables.keySet.map [ variableName | 
			val isConstantReference = constantReferences.contains(variableName)
			val wollokObject = instanceVariables.get(variableName)
			new WVariable(variableName, System.identityHashCode(wollokObject), false, isConstantReference)
		] + #[SELF_VAR]
	}

	def simplifiedReferences() { behavior.fqn.equals(DATE) }
	
	override allReferenceNamesForDynamicDiagram() {
		if (simplifiedReferences) {
			newArrayList	
		} else {
			this.allReferenceNames.toList
		}	
	}
	
	def getProperties() {
		properties
	}

	def allMethods() {
		if (behavior.parent !== null)
			behavior.methods + behavior.parent.methods
		else
			behavior.methods
	}
	
	def toWollokString() {
		val string = call("toString", #[])
		(string.getNativeObject(STRING) as JavaWrapper<String>).wrapped //TODO: Usar las conversion extensions
	}

	override toString() {
		try {
			// TODO: java string shouldn't call wollok string
			// it should be a low-lever WollokVM debugging method
			toWollokString
		} // this is a hack while literal objects are not inheriting from wollok.lang.Object therefore
		// they don't understand the toString() message
		catch (WollokProgramExceptionWrapper e) {
			if (e.isMessageNotUnderstood) {
				this.behavior.objectDescription
			} else
				throw e
		}
	}

	def getKind() { behavior }

	def isVoid() { this == getVoid(interpreter as WollokInterpreter, behavior) }

	def isKindOf(WMethodContainer c) { behavior.isKindOf(c) }

	// observable
	var Set<WollokObjectListener> listeners = newHashSet

	static val EMPTY_OBJECTS_ARRAY = newArrayOfSize(0)

	def addFieldChangedListener(WollokObjectListener listener) { this.listeners.add(listener) }

	def removeFieldChangedListener(WollokObjectListener listener) { this.listeners.remove(listener) }

	override addReference(String variable, WollokObject value, boolean constant) {
		if (constant) {
			constantReferences.add(variable)
		}
		setReference(variable, value)
		value
	}

	override addGlobalReference(String name, WollokObject value, boolean constant) {
		interpreter.addGlobalReference(name, value)
	}

	override removeGlobalReference(String name) {
		interpreter.removeGlobalReference(name)
	}

	def <T> getNativeObject(Class<T> clazz) { this.nativeObjects.values.findFirst[clazz.isInstance(it)] as T }

	def <T> getNativeObject(String clazz) {
		val transformedClassName = DefaultNativeObjectFactory.wollokToJavaFQN(clazz)
		this.nativeObjects.values.findFirst[transformedClassName == class.name] as T
	}

	def hasNativeType(String type) {
		val transformedClassName = DefaultNativeObjectFactory.wollokToJavaFQN(type)
		nativeObjects.values.exists[n|n.class.name == transformedClassName]
	}

	def callSuper(WMethodContainer superFrom, String message, WollokObject[] parameters) {
		val hierarchy = behavior.linearizeHierarchy
		val subhierarchy = hierarchy.subList(hierarchy.indexOf(superFrom) + 1, hierarchy.size)

		val method = subhierarchy.fold(null) [ method, t |
			if (method !== null)
				method
			else
				t.methods.findFirst[matches(message, parameters)]
		]

		if (method === null) {
			if (message.hasProperty) {
				return resolveProperty(message, parameters)
			} else {
				throw throwMessageNotUnderstood(this, message, parameters)
			}
		}
			
		method.call(parameters)
	}

	override showableInStackTrace() { true }

	override variableShowableInDynamicDiagram(String name) { true }
	
}

/**
 * @author jfernandes
 */
interface WollokObjectListener {
	def void fieldChanged(String fieldName, Object oldValue, Object newValue)
}

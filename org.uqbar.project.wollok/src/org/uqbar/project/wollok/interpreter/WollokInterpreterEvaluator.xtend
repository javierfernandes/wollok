package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import java.lang.ref.WeakReference
import java.math.BigDecimal
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.adapter.mumuki.MumukiAdapter
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.CallableSuper
import org.uqbar.project.wollok.interpreter.core.LazyWollokObject
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.NodeAware
import org.uqbar.project.wollok.interpreter.natives.NativeObjectFactory
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokBasicUnaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeUnaryOperations
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.scoping.WollokQualifiedNameProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * It's the real "interpreter".
 * This object implements the logic to evaluate all Expression's and programs elements.
 * WollokInterpreter provides the execution logic and control flow.
 * This one is the one that has all the particular evaluation implementations
 * for each element.
 * 
 * @author jfernandes
 * @author dodain - Added multiple files evaluation
 * 
 */
class WollokInterpreterEvaluator implements XInterpreterEvaluator<WollokObject> {
	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations
	extension WollokBasicUnaryOperations = new WollokDeclarativeNativeUnaryOperations
	extension MumukiAdapter = new MumukiAdapter

	// caches
	var Map<String, WeakReference<WollokObject>> numbersCache = newHashMap
	var WollokObject trueObject
	var WollokObject falseObject

	@Inject protected WollokInterpreter interpreter
	@Inject WollokQualifiedNameProvider qualifiedNameProvider
	@Inject WollokClassFinder classFinder
	@Inject extension NativeObjectFactory nativesFactory

	/* HELPER METHODS */
	/** helper method to evaluate an expression going all through the interpreter and back here. */
	protected def eval(EObject e) { interpreter.eval(e) }

	protected def evalAll(Iterable<? extends EObject> all) {
		all.fold(null) [ a, e |
			e.eval
		]
	}

	protected def WollokObject[] evalEach(EList<? extends EObject> objects) { objects.map[eval] }

	protected def EvaluationContext<WollokObject> currentContext() {
		interpreter.currentContext
	}

	/* BINARY */
	override resolveBinaryOperation(String operator) { operator.asBinaryOperation }

	override evaluateAll(List<EObject> eObjects, String folder) {
		// By default it does nothing
	}

	// EVALUATIONS (as multimethods)
	def dispatch WollokObject evaluate(WFile it) {
		// Files are not allowed to have both a main program and tests at the same time.
		if (main !== null)
			main.eval
		else {
			if(suites !== null) suites.evalAll else tests.evalAll
		}
	}

	def dispatch WollokObject evaluate(WClass it) {}

	def dispatch WollokObject evaluate(WPackage it) {}

	def dispatch WollokObject evaluate(WProgram it) {
		programStarted 
		elements.evalAll
	}

	def dispatch WollokObject evaluate(WTest it) { elements.evalAll }

	def dispatch WollokObject evaluate(WSuite it) {
		val initMethod = initializeMethod
		tests.fold(null) [ a, test |
			members.forEach[m|evaluate(m)]
			initMethod.evaluate
			test.eval
		]
	}

	def dispatch WollokObject evaluate(WMethodDeclaration it) {}

	def dispatch WollokObject evaluate(WVariableDeclaration it) {
		if (isGlobal) {
			interpreter.currentContext.addGlobalReference(variable.variableName, right?.eval, !writeable)
		} else {
			interpreter.currentContext.addReference(variable.variableName, right?.eval, !writeable)
		}
		getVoid(interpreter as WollokInterpreter, it)
	}

	def dispatch WollokObject evaluate(WVariableReference it) {
		if (ref.name === null) {
			throw new UnresolvableReference(Messages.LINKING_COULD_NOT_RESOLVE_REFERENCE.trim + " " + astNode.text.trim)
		}

		if(ref.isGlobal) ref.ensureInitialization
		interpreter.currentContext.resolve(ref.variableName)
	}

	def variableName(WReferenciable it) { if(isGlobal) qualifiedName else name }

	def dispatch WollokObject evaluate(WIfExpression it) {
		val cond = condition.eval

		// I18N !
		if (cond === null) {
			throw newWollokExceptionAsJava(NLS.bind(Messages.WollokInterpreter_cannot_use_null_in_if, NULL))
		}
		if (!(cond.isWBoolean)) {
			throw newWollokExceptionAsJava(NLS.bind(Messages.WollokInterpreter_expression_in_if_must_evaluate_to_boolean, cond, cond?.behavior?.name))
		}
		if (wollokToJava(cond, Boolean) == Boolean.TRUE)
			then.eval
		else
			^else?.eval
	}

	def dispatch WollokObject evaluate(WTry t) {
		try
			t.expression.eval
		catch (WollokProgramExceptionWrapper e) {
			val cach = t.catchBlocks.findFirst[it.matches(e.wollokException)]
			if (cach !== null) {
				cach.evaluate(e)
			} else
				throw e
		} finally {
			t.alwaysExpression?.eval
		}
	}

	def evaluate(WCatch it, WollokProgramExceptionWrapper e) {
		val context = createEvaluationContext(e.wollokException).then(interpreter.currentContext)
		interpreter.performOnStack(it, context) [|
			expression.eval
		]
	}

	def createEvaluationContext(WCatch wCatch, WollokObject exception) {
		createEvaluationContext(wCatch.exceptionVarName.name, exception)
	}

	def dispatch WollokObject evaluate(WThrow t) {
		// this must be checked!
		val obj = t.exception.eval as WollokObject
		throw new WollokProgramExceptionWrapper(obj, t)
	}

	def boolean matches(WCatch cach, WollokObject it) {
		cach.exceptionType === null || isKindOf(cach.exceptionType)
	}

	// literals
	def dispatch WollokObject evaluate(WStringLiteral it) { newInstanceWithWrapped(STRING, value) }

	def dispatch WollokObject evaluate(WBooleanLiteral it) { booleanValue(it.isIsTrue) }

	def dispatch WollokObject evaluate(WNullLiteral it) { null }

	def dispatch WollokObject evaluate(WNumberLiteral it) { value.getOrCreateNumber }

	def getOrCreateNumber(String value) {
		val roundedValue = "" + new BigDecimal(value).adaptValue
		if (numbersCache.containsKey(roundedValue) && numbersCache.get(roundedValue).get !== null) {
			numbersCache.get(roundedValue).get
		} else {
			val n = instantiateNumber(roundedValue)
			numbersCache.put(roundedValue, new WeakReference(n))
			n
		}
	}

	def booleanValue(boolean isTrue) {
		if (isTrue) {
			if (trueObject === null)
				trueObject = newInstanceWithWrapped(BOOLEAN, isTrue)
			return trueObject
		} else {
			if (falseObject === null)
				falseObject = newInstanceWithWrapped(BOOLEAN, isTrue)
			return falseObject
		}
	}

	def theTrue() { booleanValue(true) }

	def theFalse() { booleanValue(false) }

	def <T> newInstanceWithWrapped(String className, T wrapped) {
		newInstance(className) => [
			val native = getNativeObject(className) as JavaWrapper<T>
			native.wrapped = wrapped
		]
	}

	def instantiateNumber(String value) {
		doInstantiateNumber(NUMBER, new BigDecimal(value).adaptValue)
	}

	def doInstantiateNumber(String className, Object value) {
		val obj = newInstance(className)
		// hack because this project doesn't depend on wollok.lib project so we don't see the classes !
		val intNative = obj.getNativeObject(className) as JavaWrapper<Object>
		intNative.wrapped = value
		obj
	}

	def dispatch evaluate(WObjectLiteral l) {
		new WollokObject(interpreter, l) => [ wo |
			// 1. adding attributes: mixins call - mixin linearization - class hierarchy
			l.addObjectMembers(wo)
			l.parent.addInheritsMembers(wo)
			l.addMixinsMembers(wo)
			// 2. initialized named parameters
			if (l.hasParentParameterInitializers) {
				wo.initializeObject(l.parentParameters.initializers)
			}
			// 3. initialize pending attributes (not passed in named parameters)
			l.mixins.forEach [ initializeMembers(wo) ]
			l.parent.initializeMembers(wo)			
			l.variableDeclarations.forEach [ wo.initializeAttribute(it) ]
			// 4. last initialization opportunity - initialize method
			wo.callInitIfDefined
		]
	}

	def static callInitIfDefined(WollokObject wo) {
		val clazz = wo.behavior
		val initMethod = clazz.initMethod
		if (initMethod !== null) {
			wo.call(initMethod, #[])
		}
	}

	def addObjectMembers(WMethodContainer it, WollokObject wo) {
		members.forEach[ wo.addMember(it) ]
	}

	def addInheritsMembers(WClass it, WollokObject wo) {
		superClassesIncludingYourselfTopDownDo [
			addMembersTo(wo)
			if(native) wo.nativeObjects.put(it, createNativeObject(wo, interpreter))
		]
	}

	def initializeMembers(WClass clazz, WollokObject wo) {
		clazz.allVariableDeclarations
			.forEach [ wo.initializeAttribute(it) ]
	}

	def addMixinsMembers(WMethodContainer it, WollokObject wo) {
		mixins.forEach[addMembersTo(wo)]
	}

	def initializeMembers(WMethodContainer it, WollokObject wo) {
		variableDeclarations.forEach[wo.initializeAttribute(it)]
	}

	def dispatch evaluate(WReturnExpression it) {
		throw new ReturnValueException(expression.eval)
	}

	def dispatch evaluate(WConstructorCall call) {
		if (call.classRef.eResource === null) {
			throw newWollokExceptionAsJava(Messages.LINKING_COULD_NOT_RESOLVE_REFERENCE + call.classNameWhenInvalid)
		}
		val wollokClass = call.classRef
		val container = if (call.mixins.isEmpty) wollokClass else new MixedMethodContainer(call.classRef, call.mixins) 
		new WollokObject(interpreter, container) => [ wo |
			// 1. adding attributes: mixins call - mixin linearization - class hierarchy
			call.mixins.forEach[ addMembersTo(wo) ]
			wollokClass.addMixinsMembers(wo)
			wollokClass.addInheritsMembers(wo)
			// 2. initialized named parameters
			wo.initializeObject(call.initializers)
			// 3. initialize pending attributes (not passed in named parameters)
			wollokClass.initializeMembers(wo)
			call.mixins.forEach[ initializeMembers(wo) ]
			// 4. last initialization opportunity - initialize method
			wo.callInitIfDefined
		]
	}

	def newInstance(String classFQN, WollokObject... arguments) {
		newInstance(classFinder.searchClass(classFQN, interpreter.rootContext), arguments)
	}

	def newInstance(WClass wollokClass, WollokObject... arguments) {
		wollokClass.createInstance
	}

	def WollokObject createInstance(WClass wollokClass) {
		new WollokObject(interpreter, wollokClass) => [ wo |
			// 1. adding attributes: mixin linearization - class hierarchy
			wollokClass.addMixinsMembers(wo)
			wollokClass.addInheritsMembers(wo)
			// 3. initialize pending attributes
			wollokClass.initializeMembers(wo)
			// Here we should NOT call to the initialize method, because
			// it would override the values we want to have
		]
	}

	def dispatch WollokObject evaluate(WClosure l) {
		newInstance(CLOSURE) => [
			(getNativeObject(CLOSURE) as NodeAware<WClosure>).EObject = l
		]
	}

	def dispatch WollokObject evaluate(WListLiteral it) { 
		createCollection(LIST, elements)
	}

	def dispatch WollokObject evaluate(WSetLiteral it) {
		createCollection(SET, elements)
	}

	def createCollection(String collectionName, List<WExpression> elements) {
		newInstance(collectionName) => [
			elements.forEach [ e |
				call("add", e.eval)
			]
		]
	}

	// other expressions
	def dispatch WollokObject evaluate(WBlockExpression b) {
		if (b.expressions.isEmpty)
			return getVoid(interpreter as WollokInterpreter, b)

		b.expressions.evalAll
	}

	def dispatch WollokObject evaluate(WAssignment a) {
		val newValue = a.value.eval
		interpreter.currentContext.setReference(a.feature.ref.name, newValue)
		getVoid(interpreter as WollokInterpreter, a)
	}

	// ********************************************************************************************
	// ** Operations (unary, binary, multiops, postfix)
	// ********************************************************************************************
	def dispatch WollokObject evaluate(WBinaryOperation binary) {
		if (binary.isMultiOpAssignment) {
			val reference = binary.leftOperand
			reference.performOpAndUpdateRef(binary.operator, binary.rightOperand.lazyEval)
		} else {
			val leftOperand = binary.leftOperand.eval
			val operation = binary.feature
			validateNullOperand(leftOperand, operation)
			validateVoidOperand(leftOperand, binary.leftOperand)
			operation.asBinaryOperation.apply(leftOperand, binary.rightOperand.lazyEval) // this is just for the null == null comparisson. Otherwise is re-retrying to convert
			.javaToWollok
		}

	}

	private def validateNullOperand(WollokObject leftOperand, String operation) {
		if (leftOperand === null && !#["==", "!=", "===", "!=="].contains(operation)) {
			throw newWollokExceptionAsJava(
				NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, NULL, operation))
		}
	}

	def lazyEval(EObject expression) {
		val lazyContext = interpreter.currentContext
		return [|
			interpreter.performOnStack(expression, lazyContext, [|
				val result = expression.eval
				result.validateVoidOperand(expression as WExpression)
				result
			])
		]
	}

	def dispatch WollokObject evaluate(WPostfixOperation op) {
		op.operand.performOpAndUpdateRef(op.feature.substring(0, 1), [|getOrCreateNumber("1")])
	}

	/**
	 * A method reused between opmulti and post fix. Since it performs an binary operation applied
	 * to a reference, and then updates the value in the context (think of +=, or ++, they have common behaviors)
	 */
	def performOpAndUpdateRef(WExpression reference, String operator, ()=>WollokObject rightPart) {
		validateNullOperand(reference.eval, operator)
		val variableName = (reference as WVariableReference).ref.name
		if (variableName === null) {
			throw new UnresolvableReference(Messages.LINKING_COULD_NOT_RESOLVE_REFERENCE.trim + " " +
				reference.astNode.text)
		}
		val newValue = operator.asBinaryOperation.apply(reference.eval, rightPart).javaToWollok

		interpreter.currentContext.setReference(variableName, newValue)
		getVoid(interpreter as WollokInterpreter, reference)
	}

	def dispatch WollokObject evaluate(WUnaryOperation oper) {
		val operation = oper.feature
		val leftOperand = oper.operand.eval
		validateNullOperand(leftOperand, operation)
		validateVoidOperand(leftOperand, oper.operand)
		operation.asUnaryOperation.apply(leftOperand)
	}

	def dispatch WollokObject evaluate(WSelf t) { interpreter.currentContext.thisObject }

	// member call
	def dispatch WollokObject evaluate(WFeatureCall call) {
		val target = call.evaluateTarget
		val memberTarget = call.memberTarget
		if (target === null) {
			throw newWollokExceptionAsJava(
				NLS.bind(Messages.WollokDslValidator_REFERENCE_UNINITIALIZED, memberTarget.sourceCode.trim))
		}
		
		if (target.isVoid(call) && memberTarget !== null && !ignoreVoidValidation) {
			throw newWollokExceptionAsJava(
				NLS.bind(Messages.WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES,
					memberTarget.sourceCode.trim))
		}
		val parameters = call.memberCallArguments.evalEach
		parameters.forEach[param, i|param.validateVoidOperand(call.memberCallArguments.get(i))]
		target.call(call.feature, parameters)
	}
	
	private def void validateVoidOperand(WollokObject o, WExpression expression) {
		if (o !== null && o.isVoid(expression) && !ignoreVoidValidation) {
			throw newWollokExceptionAsJava(
				NLS.bind(Messages.WollokDslValidator_VOID_MESSAGES_CANNOT_BE_USED_AS_VALUES,
					expression.sourceCode.trim))
		}
	}

	// ********************************************************************************************
	// ** Initialization of objects and references
	// ********************************************************************************************
	def initializeObject(WollokObject wollokObject, EList<WInitializer> namedParameters) {
		namedParameters.forEach([ namedParameter |
			val value = 
				if (namedParameter.initialValue.shouldBeLazilyInitialized)
					new LazyWollokObject(interpreter, wollokObject.behavior, [ | namedParameter.initialValue.eval ])
				else
					namedParameter.initialValue.eval

			wollokObject.setReference(namedParameter.initializer.name, value)			
		])
	}

	def void ensureInitialization(WReferenciable it) {
		try {
			// Tries to get value but is never used, could be improved.
			interpreter.currentContext.resolve(qualifiedName)
		} catch (UnresolvableReference e) {
			initializeReference
		}
	}
	
	def dispatch void initializeReference(WNamedObject it) { createNamedObject(qualifiedName) }

	def dispatch void initializeReference(WVariable it) { eContainer.eval }

	def createNamedObject(WNamedObject namedObject, String qualifiedName) {
		new WollokObject(interpreter, namedObject) => [ wollokObject |
			// first add it to solve cross-refs !
			interpreter.currentContext.addGlobalReference(qualifiedName, wollokObject, true)
			try {
				// 1. adding attributes: mixin linearization - class hierarchy
				namedObject.addMixinsMembers(wollokObject)
				namedObject.parent.addInheritsMembers(wollokObject)
				namedObject.addObjectMembers(wollokObject)

				if (namedObject.native)
					wollokObject.nativeObjects.put(namedObject,
						namedObject.createNativeObject(wollokObject, interpreter))

				// 2. initialized named parameters over the parent (if it has)
				if (namedObject.hasParentParameterInitializers)
					wollokObject.initializeObject(namedObject.parentParameters.initializers)

				// 3. initialize pending attributes (not passed in named parameters)
				namedObject.mixins.forEach [ initializeMembers(wollokObject) ]
				namedObject.parent.initializeMembers(wollokObject)
				namedObject.initializeMembers(wollokObject)			

				// 4. last initialization opportunity - initialize method
				wollokObject.callInitIfDefined
			} catch (RuntimeException e) {
				// if init failed remove it !
				interpreter.currentContext.removeGlobalReference(qualifiedName)
				throw e
			}
		]
	}

	def qualifiedName(EObject it) {
		qualifiedNameProvider.getFullyQualifiedName(it).toString
	}

	// ********************************************************************************************
	// ** Helpers
	// ********************************************************************************************
	def dispatch evaluateTarget(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }

	def dispatch evaluateTarget(WMemberFeatureCall call) { call.memberCallTarget.eval }

	def dispatch evaluateTarget(WSuperInvocation call) { new CallableSuper(interpreter, call.declaringContext) }

	def WollokObject getWKObject(String qualifiedName, EObject context) {
		try {
			interpreter.currentContext.resolve(qualifiedName)
		} catch (UnresolvableReference e) {
			createNamedObject(classFinder.getCachedObject(context, qualifiedName), qualifiedName)
		}
	}

	def dispatch isVoid(WollokObject object, EObject context) { object === getVoid(interpreter, context) }
	def dispatch isVoid(CallableSuper call, EObject context) { false }
}

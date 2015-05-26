package org.uqbar.project.wollok.validation

import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WLibrary
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamed
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.WollokDSLKeywords.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

/**
 * Custom validation rules.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 * 
 * @author jfernandes
 */
// TODO: abstract a new generic Validator that is integrated with a preferences mechanism
// that will allow to enabled/disabled checks, and maybe even configure the issue severity for some
// like "error/warning/ignore". It could be completely automatically based on annotations.
// Ex:
//  @Check @ConfigurableSeverity @EnabledDisabled
class WollokDslValidator extends AbstractWollokDslValidator {
	List<WollokValidatorExtension> wollokValidatorExtensions

	// ERROR KEYS	
	public static val CANNOT_ASSIGN_TO_VAL = "CANNOT_ASSIGN_TO_VAL"
	public static val CANNOT_ASSIGN_TO_NON_MODIFIABLE = "CANNOT_ASSIGN_TO_NON_MODIFIABLE"
	public static val CLASS_NAME_MUST_START_UPPERCASE = "CLASS_NAME_MUST_START_UPPERCASE"
	public static val REFERENCIABLE_NAME_MUST_START_LOWERCASE = "REFERENCIABLE_NAME_MUST_START_LOWERCASE"
	public static val METHOD_ON_THIS_DOESNT_EXIST = "METHOD_ON_THIS_DOESNT_EXIST"
	public static val METHOD_MUST_HAVE_OVERRIDE_KEYWORD = "METHOD_MUST_HAVE_OVERRIDE_KEYWORD" 
	public static val ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS = "ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS"
	public static val TYPE_SYSTEM_ERROR = "TYPE_SYSTEM_ERROR"
	
	// WARNING KEYS
	public static val WARNING_UNUSED_VARIABLE = "WARNING_UNUSED_VARIABLE"
	
	def validatorExtensions(){
		if(wollokValidatorExtensions != null)
			return wollokValidatorExtensions
			
		val configs = Platform.getExtensionRegistry.getConfigurationElementsFor("org.uqbar.project.wollok.wollokValidationExtension")
		wollokValidatorExtensions = configs.map[it.createExecutableExtension("class") as WollokValidatorExtension]
	}
	
	@Check
	def checkValidationExtensions(WFile wfile){
		validatorExtensions.forEach[ check(wfile, this)]
	}
	
	@Check
	def classNameMustStartWithUpperCase(WClass c) {
		if (Character.isLowerCase(c.name.charAt(0))) error("Class name must start with uppercase", c, WNAMED__NAME, CLASS_NAME_MUST_START_UPPERCASE)
	}
	
	@Check
	def referenciableNameMustStartWithLowerCase(WReferenciable c) {
		if (Character.isUpperCase(c.name.charAt(0))) error("Referenciable name must start with lowercase", c, WNAMED__NAME, REFERENCIABLE_NAME_MUST_START_LOWERCASE)
	}
	
	// **************************************
	// ** instantiation and constructors	
	// **************************************

	@Check
	def checkCannotInstantiateAbstractClasses(WConstructorCall c) {
		if(c.classRef.isAbstract) error("Cannot instantiate abstract class", c, WCONSTRUCTOR_CALL__CLASS_REF)
	}

	@Check
	def checkConstructorCall(WConstructorCall c) {
		if (!c.isValidConstructorCall()) {
			val expectedMessage = if (c.classRef.constructors == null)
					""
				else
					c.classRef.constructors.map[ '(' + parameters.map[name].join(",") + ')'].join(' or ')
			error("Wrong number of arguments. Should be " + expectedMessage, c, WCONSTRUCTOR_CALL__ARGUMENTS)
		}
	}
	
	@Check
	def checkRequiredSuperClassConstructorCall(WClass it) {
		if (!hasConstructorDefinitions && superClassRequiresNonEmptyConstructor) 
			error('''No default constructor in super type «parent.name». «name» must define an explicit constructor.''', it, WNAMED__NAME)
	}
	
	@Check
	def checkCannotHaveTwoConstructorsWithSameArity(WClass it) {
		val repeated = constructors.filter[c | constructors.exists[c2 | c != c2 && c.parameters.size == c2.parameters.size ]]
		repeated.forEach[r|
			error("Duplicated constructor with same number of parameters", r, WCONSTRUCTOR__PARAMETERS)
		]
	}
	
	@Check
	def checkConstrutorMustExpliclityCallSuper(WConstructor it) {
		if (delegatingConstructorCall == null && wollokClass.superClassRequiresNonEmptyConstructor) {
			error("Must call a super class constructor explicitly", it.wollokClass, WCLASS__CONSTRUCTORS, wollokClass.constructors.indexOf(it))
		}
	}
	
	@Check
	def checkDelegatedConstructorExists(WDelegatingConstructorCall it) {
		try {
			val resolved = it.wollokClass.resolveConstructorReference(it)
			if (resolved == null) {
				// we could actually show the available options
				error("Invalid constructor call. Does Not exist", it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL)
			}
		}
		catch (WollokRuntimeException e) {
			// mmm... terrible
			error("Invalid constructor call. Does Not exist", it.eContainer, WCONSTRUCTOR__DELEGATING_CONSTRUCTOR_CALL)
		}
	}
	
	// **************************************
	// ** overriding	
	// **************************************

	@Check
	def checkMethodActuallyOverrides(WMethodDeclaration m) {
		val overrides = m.actuallyOverrides
		if(m.overrides && !overrides) m.error("Method does not overrides anything")
		if (overrides && !m.overrides)
			m.error("Method must be marked as overrides, since it overrides a superclass method", METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	}

	@Check
	def checkCannotAssignToVal(WAssignment a) {
		if(!a.feature.ref.isModifiableFrom(a)) error("Cannot modify values", a, WASSIGNMENT__FEATURE, cannotModifyErrorId(a.feature))
	}
	def dispatch String cannotModifyErrorId(WReferenciable it) { CANNOT_ASSIGN_TO_NON_MODIFIABLE }
	def dispatch String cannotModifyErrorId(WVariableDeclaration it) { CANNOT_ASSIGN_TO_VAL }
	def dispatch String cannotModifyErrorId(WVariableReference it) { cannotModifyErrorId(ref) }

	@Check
	def duplicated(WMethodDeclaration m) {
		if (m.declaringContext.members.filter(WMethodDeclaration).exists[it != m && it.name == m.name])
			m.error("Duplicated method")
	}

	@Check
	def duplicated(WReferenciable p) {
		if(p.isDuplicated) p.error("Duplicated name")
	}

	@Check
	def methodInvocationToThisMustExist(WMemberFeatureCall call) {
		if (call.callOnThis && call.method != null && !call.method.declaringContext.isValidCall(call)) {
			error("Method does not exist or invalid number of arguments", call, WMEMBER_FEATURE_CALL__FEATURE, METHOD_ON_THIS_DOESNT_EXIST)
		}
	}

	@Check
	def unusedVariables(WVariableDeclaration it) {
		val assignments = variable.assignments
		if (assignments.empty) {
			if (writeable)
				warning('''Variable is never assigned''', it, WVARIABLE_DECLARATION__VARIABLE)
			else if (!writeable)
				error('''Variable is never assigned''', it, WVARIABLE_DECLARATION__VARIABLE)	
		}
		if (variable.uses.empty)
			warning('''Unused variable''', it, WVARIABLE_DECLARATION__VARIABLE, WARNING_UNUSED_VARIABLE)
	}
	
	@Check
	def superInvocationOnlyInValidMethod(WSuperInvocation sup) {
		val body = sup.method.expression as WBlockExpression
		if (sup.method.declaringContext instanceof WObjectLiteral)
			error("Super can only be used in a method belonging to a class", body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
		else if (!sup.method.overrides)
			error("Super can only be used in an overriding method", body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
		else if (sup.memberCallArguments.size != sup.method.parameters.size)
			error('''Incorrect number of arguments for super. Expecting «sup.method.parameters.size» for: «sup.method.overridenMethod.parameters.map[name].join(", ")»''', body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
	}
	
	// ***********************
	// ** Exceptions
	// ***********************
	
	@Check
	def tryMustHaveEitherCatchOrAlways(WTry tri) {
		if ((tri.catchBlocks == null || tri.catchBlocks.empty) && tri.alwaysExpression == null)
			error("Try block must specify either a 'catch' or a 'then always' clause", tri, WTRY__EXPRESSION, ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	}
	
	@Check 
	def catchExceptionTypeMustExtendException(WCatch it) {
		if (!exceptionType.exception) error("Can only catch wollok.lang.Exception or a subclass of it", it, WCATCH__EXCEPTION_TYPE)
	}
	
// requires type system in order to infer type of the WExpression being thrown ! "throw <??>"
//	@Check
//	def canOnlyThrowExceptionTypeObjects(WThrow it) {
//		if (!it.exception.type.isException) error("Can only throw wollok.lang.Exception or a subclass of it", it, WCATCH__EXCEPTION_TYPE)
//	}
	
	@Check
	def postFixOpOnlyValidforVarReferences(WPostfixOperation op) {
		if (!(op.operand.isVarRef))
			error(op.feature + " can only be applied to variable references", op, WPOSTFIX_OPERATION__OPERAND)
	}
	
	@Check
	def classNameCannotBeDuplicatedWithinPackage(WPackage p) {
		val classes = p.elements.filter(WClass)
		val repeated = classes.filter[c| classes.exists[it != c && name == c.name] ]
		repeated.forEach[
			error('''Duplicated class name in package «p.name»''', it, WNAMED__NAME)
		]
	}
	
	@Check 
	def avoidDuplicatedPackageName(WPackage p) {
		if (p.eContainer.eContents.filter(WPackage).exists[it != p && name == p.name])
			error('''Duplicated package name «p.name»''', p, WNAMED__NAME)
	}
	
	@Check
	def multiOpOnlyValidforVarReferences(WBinaryOperation op) {
		if (op.feature.isMultiOpAssignment && !op.leftOperand.isVarRef)
			error(op.feature + " can only be applied to variable references", op, WBINARY_OPERATION__LEFT_OPERAND)
	}
	
	@Check
	def programInProgramFile(WProgram p){
		if(p.eResource.URI.nonXPectFileExtension != WollokConstants.PROGRAM_EXTENSION)
			error('''Program «p.name» should be in a file with extension «WollokConstants.PROGRAM_EXTENSION»''', p, WPROGRAM__NAME)					
	}

	@Check
	def libraryInLibraryFile(WLibrary l){
		if(l.eResource.URI.nonXPectFileExtension != WollokConstants.CLASS_OBJECTS_EXTENSION) 
			error('''Classes and Objects should be defined in a file with extension «WollokConstants.CLASS_OBJECTS_EXTENSION»''', l, WLIBRARY__ELEMENTS)		
	}

	def isVarRef(WExpression e) { e instanceof WVariableReference }

	/**
	 * Returns the "wollok" file extension o a file, ignoring a possible final ".xt"
	 * 
	 * This is a workaround for XPext testing. XPect test definition requires to add ".xt" to program file names, 
	 * therefore fileExtension-dependent validations will fail if this is not taken into account.
	 */
	def nonXPectFileExtension(URI uri) {
		if (uri.fileExtension == 'xt') {
			val fileName = uri.segments.last()
			val fileNameParts = fileName.split("\\.")
			fileNameParts.get(fileNameParts.length - 2) // Penultimate part (last part is .xt)
		}
		else uri.fileExtension
	}

	// ******************************	
	// native methods
	// ******************************
	
	@Check
	def nativeMethodsChecks(WMethodDeclaration it) {
		if (native) {
			 if (expression != null) error("Native methods cannot have a body", it, WMETHOD_DECLARATION__EXPRESSION)
			 if (overrides) error("Native methods cannot override anything", it, WMETHOD_DECLARATION__OVERRIDES)
			 if (declaringContext instanceof WObjectLiteral) error("Native methods can only be defined in classes", it, WMETHOD_DECLARATION__NATIVE)
			 // this is currently a limitation on native objects
			 if(declaringContext instanceof WClass)
				 if ((declaringContext as WClass).parent != null && (declaringContext as WClass).parent.native)
				 	error("Cannot declare native methods in this class since there's already a native super class in the hierarchy", it, WMETHOD_DECLARATION__NATIVE)
		}
	}

	// ******************************
	// ** is duplicated impl (TODO: move it to extensions)
	// ******************************
	
	def boolean isDuplicated(WReferenciable reference) {
		reference.eContainer.isDuplicated(reference)
	}

	// Root objects (que no tiene acceso a variables fuera de ellos)
	def dispatch boolean isDuplicated(WClass c, WReferenciable v) { c.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WProgram p, WReferenciable v) {  p.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WTest p, WReferenciable v) { p.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WLibrary wl, WReferenciable r){ wl.elements.existsMoreThanOne(r) }
	def dispatch boolean isDuplicated(WNamedObject c, WReferenciable r) { c.variables.existsMoreThanOne(r) }

	def dispatch boolean isDuplicated(WPackage p, WNamedObject r){
		p.namedObjects.existsMoreThanOne(r)
	}

	def dispatch boolean isDuplicated(WMethodDeclaration m, WReferenciable v) {
		m.parameters.existsMoreThanOne(v) || m.declaringContext.isDuplicated(v)
	}

	def dispatch boolean isDuplicated(WBlockExpression c, WReferenciable v) {
		c.expressions.existsMoreThanOne(v) || c.eContainer.isDuplicated(v)
	}

	def dispatch boolean isDuplicated(WClosure c, WReferenciable r) {
		c.parameters.existsMoreThanOne(r) || c.eContainer.isDuplicated(r)
	}

	def dispatch boolean isDuplicated(WConstructor c, WReferenciable r) {
		c.parameters.existsMoreThanOne(r) || c.eContainer.isDuplicated(r)
	}

	// default case is to delegate up to container
	def dispatch boolean isDuplicated(EObject e, WReferenciable r) {
		e.eContainer.isDuplicated(r)
	}

	def existsMoreThanOne(Iterable<?> exps, WReferenciable ref) {
		exps.filter(WReferenciable).exists[it != ref && name == ref.name]
	}

	// ******************************
	// ** extensions to validations.
	// ******************************
	
	def error(WNamed e, String message) { error(message, e, WNAMED__NAME) }
	def error(WNamed e, String message, String errorId) { error(message, e, WNAMED__NAME, errorId) }
		
}

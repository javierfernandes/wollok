package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ConcreteType

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		// TODO: Uncomment all definitions when solving closure parameters
		(Object == Any) => Boolean;
		Object >> "equals" === #[Any] => Boolean;
		Object >> "toString" === #[] => String;
		Object >> "printString" === #[] => String;
		Object >> "internalToSmartString" === #[Boolean] => String;

		(Boolean == Any) => Boolean
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean
		Boolean >> "toString" === #[] => String;

		PairType.constructor(PKEY, PVALUE)
		PairType >> "key" === #[] => PKEY;
		PairType >> "value" === #[] => PVALUE;

		Number + Number => Number
		Number - Number => Number
		Number * Number => Number
		Number >> "/" === #[Number] => Number
		Number >> "div" === #[Number] => Number
		Number >> "rem" === #[Number] => Number
		Number >> "**" === #[Number] => Number
		Number >> ">" === #[Number] => Boolean
		Number >> "<" === #[Number] => Boolean
		Number >> ">=" === #[Number] => Boolean
		Number >> "<=" === #[Number] => Boolean
		Number / Number => Number
		Number >> "between" === #[Number, Number] => Boolean
		Number % Number => Number
		Number >> "toString" === #[] => String
		Number >> "invert" === #[] => Number
		Number >> "abs" === #[] => Number
		Number >> "limitBetween" === #[Number, Number] => Number
		Number >> ".." === #[Number] => Range
		Number >> "max" === #[Number] => Number
		Number >> "min" === #[Number] => Number
		Number >> "square" === #[] => Number
		Number >> "squareRoot" === #[] => Number
		Number >> "even" === #[] => Boolean
		Number >> "odd" === #[] => Boolean
		Number >> "roundUp" === #[] => Number
		Number >> "roundUp" === #[Number] => Number
		Number >> "truncate" === #[Number] => Number;
		Number >> "randomUpTo" === #[Number] => Number;
		Number >> "gcd" === #[Number] => Number;
		Number >> "lcm" === #[Number] => Number;
		Number >> "digits" === #[] => Number;
		Number >> "isInteger" === #[] => Boolean;
		Number >> "isPrime" === #[] => Boolean;
		Number >> "plus" === #[] => Number;
		Number >> "times" === #[closure(#[Number], Void)] => Void;
		Number >> "checkNotNull" === #[Any, String] => Void;
		Number >> "simplifiedToSmartString" === #[] => String;
		Number >> "internalToSmartString" === #[Boolean] => String;
		Number >> "coerceToInteger" === #[] => Number;

		(String == Any) => Boolean
		String >> "length" === #[] => Number
		String >> "size" === #[] => Number
		String >> "charAt" === #[Number] => String
		String >> "startsWith" === #[String] => Boolean
		String >> "endsWith" === #[String] => Boolean
		String >> "indexOf" === #[String] => Number
		String >> "lastIndexOf" === #[String] => Number
		String >> "toUpperCase" === #[] => String
		String >> "trim" === #[] => String
		String >> "contains" === #[String] => Boolean
		String >> "isEmpty" === #[] => Boolean
		String >> "substring" === #[Number] => String
		String >> "substring" === #[Number, Number] => String
		String >> "split" === #[String] => List.of(String)
		String >> "equalsIgnoreCase" === #[String] => Boolean
		String >> "printString" === #[] => String
		String >> "toString" === #[] => String
		String >> "replace" === #[String, String] => String
		String + String => String;
		(String > String) => Boolean
		String >> "take" === #[Number] => String
		String >> "drop" === #[Number] => String
		String >> "words" === #[] => List.of(String)
		String >> "capitalize" === #[] => String

		ExceptionType >> "getMessage" === #[] => String
		ExceptionType >> "getCause" === #[] => ExceptionType
		ExceptionType >> "equals" === #[ExceptionType] => Boolean
		ExceptionType >> "printStackTrace" === #[] => Void
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List.of(String)
		ExceptionType >> "getStackTrace" === #[] => List.of(String)
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement


		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection;
		Collection >> "min" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "max" === #[closure(#[ELEMENT], Number)] => ELEMENT;
		Collection >> "internalToSmartString" === #[Boolean] => String;

		#[Collection, List, Set].forEach [
			it >> "asSet" === #[] => Set.of(ELEMENT)
			it >> "occurrencesOf" === #[ELEMENT] => Number
		]

		// TODO This should use SELF type.
		Collection >> "filter" === #[predicate] => List.of(ELEMENT);

		(List == Any) => Boolean
		List + List => List
		List >> "equals" === #[Any] => Boolean;
		List >> "add" === #[ELEMENT] => Void
		List >> "first" === #[] => ELEMENT
		List >> "drop" === #[Number] => List
		List >> "take" === #[Number] => List
		List >> "sum" === #[closure(#[ELEMENT], Number)] => Number

		#[Collection, List, Set, Range].forEach [
			it >> "isEmpty" === #[] => Boolean
			it >> "contains" === #[ELEMENT] => Boolean
			it >> "asList" === #[] => List.of(ELEMENT)

			it >> "forEach" === #[closure(#[ELEMENT], Void)] => Void
			it >> "find" === #[predicate] => ELEMENT;
			it >> "all" === #[predicate] => Boolean
			it >> "any" === #[predicate] => Boolean
			it >> "find" === #[predicate] => ELEMENT
			it >> "findOrDefault" === #[predicate, ELEMENT] => ELEMENT
			it >> "findOrElse" === #[predicate, closure(#[], ELEMENT)] => ELEMENT
			it >> "count" === #[predicate] => Number
		]

		#[Collection, List, Set, Range, Dictionary].forEach [
			it >> "size" === #[] => Number
		]

		Dictionary >> "forEach" === #[closure(#[DKEY, DVALUE], Void)] => Void;
		
		Range >> "sum" === #[closure(#[Number], Number)] => Number;
		Range >> "internalToSmartString" === #[Boolean] => String;
		Range >> "filter" === #[closure(#[Number], Boolean)] => List.of(Number);

		(Set == Any) => Boolean
		Set >> "equals" === #[Any] => Boolean;
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "sum" === #[closure(#[ELEMENT], Number)] => Number;

		Date.constructor(Number, Number, Number)
		(Date == Date) => Boolean
		Date - Date => Number
		Date >> "initialize" === #[Number, Number, Number] => Void
		Date >> "plusDays" === #[Number] => Date
		Date >> "plusMonths" === #[Number] => Date
		Date >> "plusYears" === #[Number] => Date
		Date >> "isLeapYear" === #[] => Boolean
		Date >> "day" === #[] => Number
		Date >> "dayOfWeek" === #[] => Number
		Date >> "month" === #[] => Number
		Date >> "year" === #[] => Number
		Date >> "minusDays" === #[Number] => Date
		Date >> "minusMonths" === #[Number] => Date
		Date >> "minusYears" === #[Number] => Date
		Date >> "between" === #[Date, Date] => Boolean
		Date >> "toSmartString" === #[Boolean] => String;

		Position.constructor(Number, Number)
		Position.variable("x", Number)
		Position.variable("y", Number)
		(Position == Any) => Boolean;
		Position >> "moveRight" === #[Number] => Void
		Position >> "moveLeft" === #[Number] => Void
		Position >> "moveUp" === #[Number] => Void
		Position >> "moveDown" === #[Number] => Void
		Position >> "drawElement" === #[Any] => Void
		Position >> "drawCharacter" === #[Any] => Void
		Position >> "deleteElement" === #[Any] => Void
		Position >> "say" === #[Any, String] => Void
		Position >> "allElements" === #[] => List
		Position >> "clone" === #[] => Position
		Position >> "distance" === #[Position] => Number
		Position >> "clear" === #[] => Void
		Position >> "toString" === #[] => String

//		Key >> "onPressDo" === #[closure(#[], Void)] => Void
		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => Void

		assertWKO >> "that" === #[Boolean] => Void
		assertWKO >> "notThat" === #[Boolean] => Void
		assertWKO >> "equals" === #[Any, Any] => Void
		assertWKO >> "notEquals" === #[Any, Any] => Void
		// assertWKO >> "throwsException" === #[closure(#[], Any)] => Void
		// assertWKO >> "throwsExceptionLike" === #[ExceptionType, closure(#[], Any)] => Void
		// assertWKO >> "throwsExceptionWithMessage" === #[String, closure(#[], Any)] => Void
		// assertWKO >> "throwsExceptionWithType" === #[ExceptionType, closure(#[], Any)] => Void
		// assertWKO >> "throwsExceptionByComparing" === #[closure(#[], Any), closure(#[Any], Boolean)] => Void
		assertWKO >> "fail" === #[String] => Void;

		// TODO: getter and setters are implemented because native implementations exist
		game.fakeProperty("title", String)
		game.fakeProperty("width", Number)
		game.fakeProperty("height", Number)
		game >> "addVisual" === #[Any] => Void
		game >> "addVisualIn" === #[Any, Position] => Void
		game >> "addVisualCharacter" === #[Any] => Void
		game >> "addVisualCharacterIn" === #[Any, Position] => Void
		game >> "removeVisual" === #[Any] => Void
//		game >> "whenKeyPressedDo" === #[Number, closure(#[], Void)] => Void
//		game >> "whenCollideDo" === #[Any, closure(#[Any], Void)] => Void
		game >> "getObjectsIn" === #[Position] => List
		game >> "say" === #[Any, String] => Void
		game >> "clear" === #[] => Void
		game >> "colliders" === #[Any] => List
		game >> "stop" === #[] => Void
		game >> "start" === #[] => Void
		game >> "at" === #[Number, Number] => Position
		game >> "origin" === #[] => Position
		game >> "center" === #[] => Position
		game >> "ground" === #[String] => Void
		game >> "boardGround" === #[String] => Void

		keyboard.allMethods === #[] => Key

		comparable(Number, String, Date)

		// Closure >> "apply" === #[List] => RETURN
		InstanceVariableMirror >> "value" === #[] => Void

		StringPrinter >> "println" === #[Any] => Void
		StringPrinter >> "getBuffer" === #[] => String
	}

	def comparable(SimpleTypeAnnotation<? extends ConcreteType>... types) {
		types.forEach [ T |
			(T > T) => Boolean;
			(T < T) => Boolean;
			(T <= T) => Boolean;
			(T >= T) => Boolean;
			(T === T) => Boolean;
		]
	}

	def fakeProperty(SimpleTypeAnnotation<? extends ConcreteType> it, String property,
		SimpleTypeAnnotation<? extends ConcreteType> type) {
		it >> property === #[type] => Void
		it >> property === #[] => type
	}
}

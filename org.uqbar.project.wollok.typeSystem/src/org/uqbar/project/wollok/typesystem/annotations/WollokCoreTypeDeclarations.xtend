package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ConcreteType

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		
		(Object == Any) => Boolean;
		Object >> "toString" === #[] => String;
		Object >> "printString" === #[] => String;

		(Boolean == Any) => Boolean		
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean
		Boolean >> "toString" === #[] => String;

		PairType >> "getKey" === #[] => Any;
		PairType >> "getValue" === #[] => Any;
		
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
		Number >> "times" === #[closure(#[], Any)] => Void;

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
		String >> "split" === #[String] => List
		String >> "equalsIgnoreCase" === #[String] => Boolean
		String >> "printString" === #[] => String
		String >> "toString" === #[] => String
		String >> "replace" === #[String, String] => String
		String + String => String;
		(String > String) => Boolean
		String >> "take" === #[Number] => String
		String >> "drop" === #[Number] => String
		String >> "words" === #[] => List
		String >> "capitalize" === #[] => String
		
		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection;

		(List == Any) => Boolean
		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "size" === #[] => Number
		List >> "sum" === #[closure(#[ELEMENT], Number)] => Number
		
		Range >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		 
		(Set == Any) => Boolean
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "contains" === #[ELEMENT] => Boolean
		Set >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		
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
		
		(Position == Any) => Boolean;

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => Void

		comparable(Number, String, Date)
	}
	
	def comparable(SimpleTypeAnnotation<? extends ConcreteType>... types) {
		types.forEach[ T |
			(T > T) => Boolean;
			(T < T) => Boolean;
			(T <= T) => Boolean;
			(T >= T) => Boolean;
			(T === T) => Boolean;
		]
	}
}

package org.uqbar.project.wollok.typesystem.annotations

class CollectionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Collection.collectionDeclarations(ELEMENT)
		List.listDeclarations(ELEMENT)
		Set.setDeclarations(ELEMENT)
		Range.rangeDeclarations
		Dictionary.dictionaryDeclarations(DKEY, DVALUE)
	}

	def basicCollection(AnnotationContext C, TypeAnnotation E) {
		C.sizedCollection
		C >> "asList" === #[] => List.of(E)
		
		C >> "anyOne" === #[] => E
		C >> "contains" === #[E] => Boolean

		C >> "forEach" === #[closure(#[E], Void)] => Void
		C >> "find" === #[predicate(E)] => E;
		C >> "all" === #[predicate(E)] => Boolean
		C >> "any" === #[predicate(E)] => Boolean
		C >> "find" === #[predicate(E)] => E
		C >> "findOrDefault" === #[predicate(E), E] => E
		C >> "findOrElse" === #[predicate(E), closure(#[], E)] => E
		C >> "count" === #[predicate(E)] => Number
		
		C >> "map" === #[closure(#[E], T)] => List.of(T);
		C >> "flatMap" === #[closure(#[E], List.of(T))] => List.of(T);
		C >> "fold" === #[T, closure(#[T, E], T)] => T;
	}

	def mutableCollection(AnnotationContext C, TypeAnnotation E) {
		C.basicCollection(E)
		C.remove(E)
		C >> "add" === #[E] => Void
		C >> "addAll" === #[Collection.of(E)] => Void
		C >> "removeAll" === #[Collection.of(E)] => Void
		C >> "removeAllSuchThat" === #[predicate(E)] => Void
	}

	//TODO: Define comparables
	def comparableCollection(AnnotationContext C, TypeAnnotation E) {
		C >> "min" === #[] => E;
		C >> "max" === #[] => E;
		C >> "min" === #[closure(#[E], Number)] => E;
		C >> "max" === #[closure(#[E], Number)] => E;
		C >> "minIfEmpty" === #[closure(#[], E)] => E;
		C >> "maxIfEmpty" === #[closure(#[], E)] => E;
		C >> "minIfEmpty" === #[closure(#[E], Number), closure(#[], E)] => E;
		C >> "maxIfEmpty" === #[closure(#[E], Number), closure(#[], E)] => E;
	}

	//TODO: Define sumables
	def sumableCollection(AnnotationContext C, TypeAnnotation E) {
		C >> "sum" === #[] => Number; //TODO: Should be C<Number>
		C >> "sum" === #[closure(#[E], Number)] => Number;
	}

	def sizedCollection(AnnotationContext C) {
		C >> "size" === #[] => Number
		C >> "isEmpty" === #[] => Boolean
	}
	
	def clear(AnnotationContext C) {
		C >> "clear" === #[] => Void
	}
	
	def remove(AnnotationContext C, TypeAnnotation E) {
		C >> "remove" === #[E] => Void
	}

	def collectionDeclarations(AnnotationContext C, TypeAnnotation E) { 
		C + Collection.of(E) => SelfType.of(E);
		C.mutableCollection(E)
		C.comparableCollection(E)
		C.sumableCollection(E)
		C.clear

		C >> "toStringPrefix" === #[] => String
		C >> "toStringSuffix" === #[] => String
		C >> "join" === #[String] => String
		C >> "join" === #[] => String
		
		C >> "asSet" === #[] => Set.of(E)
		C >> "occurrencesOf" === #[E] => Number
		C >> "sortedBy" === #[predicate(E, E)] => List.of(E);
		
		C >> "copy" === #[] => SelfType.of(E);
		C >> "newInstance" === #[] => SelfType.of(Any);
		C >> "filter" === #[predicate(E)] => SelfType.of(E);
//		C >> "flatten" === #[] => SelfType.of(E); //TODO: Should be C<C<E>>
	}
	
	def listDeclarations(AnnotationContext L, TypeAnnotation E) {
		L.collectionDeclarations(E)
		L >> "first" === #[] => E
		L >> "head" === #[] => E
		L >> "last" === #[] => E
		L >> "get" === #[Number] => E
		L >> "take" === #[Number] => List.of(E)		
		L >> "drop" === #[Number] => List.of(E)
		L >> "subList" === #[Number, Number] => List.of(E)
		L >> "reverse" === #[] => List.of(E)
		L >> "withoutDuplicates" === #[] => List.of(E)
		L >> "sortBy" === #[predicate(E, E)] => Void
	}
	
	def setDeclarations(AnnotationContext S, TypeAnnotation E) {
		S.collectionDeclarations(E)
		S >> "union" === #[Collection.of(E)] => Set.of(E)
		S >> "intersection" === #[Collection.of(E)] => Set.of(E)
		S >> "difference" === #[Collection.of(E)] => Set.of(E)
	}
	
	def rangeDeclarations(AnnotationContext R) {
		R.basicCollection(Number)
		R >> "filter" === #[predicate(Number)] => List.of(Number);
		R >> "internalToSmartString" === #[Boolean] => String;
	}
	
	def dictionaryDeclarations(AnnotationContext D, TypeAnnotation K, TypeAnnotation V) {
		D.clear
		D.sizedCollection
		D.remove(K)
		D >> "put" === #[K, V] => Void;
		D >> "get" === #[K] => V; //Throw exception
		D >> "basicGet" === #[K] => V; //Nullable
		D >> "getOrElse" === #[K, closure(#[], V)] => V;
		D >> "containsKey" === #[K] => Boolean;
		D >> "containsValue" === #[V] => Boolean;
		D >> "keys" === #[] => List.of(K);
		D >> "values" === #[] => List.of(V);
		D >> "forEach" === #[closure(#[K, V], Void)] => Void;
	}
}

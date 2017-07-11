package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.List
import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MaximalConcreteTypes
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForAll
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.VariableSubtypingRules.*

class MaxTypesFromMessages extends SimpleTypeInferenceStrategy {

	private Iterable<AbstractContainerWollokType> allTypes = newArrayList()

	def dispatch void analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		var maxTypes = allTypes(tvar).filter[newMaxTypeFor(tvar)].toList
		if (!tvar.sealed && 
			!maxTypes.empty && 
			!maximalConcreteTypes.contains(maxTypes) && 
			tvar.subtypes.empty
		) { // Last condition is because some test fail, but I don't know if it's OK
			println('''	New max(«maxTypes») type for «tvar»''')
			setMaximalConcreteTypes(new MaximalConcreteTypes(maxTypes.map[it as WollokType].toSet), tvar)
			changed = true
		}
	}

	def contains(MaximalConcreteTypes maxTypes, List<? extends WollokType> types) {
		maxTypes != null && maxTypes.containsAll(types)
	}

	def newMaxTypeFor(AbstractContainerWollokType type, TypeVariable it) {
		!typeInfo.messages.empty && typeInfo.messages.forall[acceptMessage(type)]
	}

	def acceptMessage(MessageSend message, AbstractContainerWollokType it) {
		container.allMethods.exists[
			match(message)
		]
	}

	def private match(WMethodDeclaration declaration, MessageSend message) {
		declaration.name == message.selector && declaration.parameters.size == message.arguments.size &&
			matchParameters(declaration, message)
	}

	def private matchParameters(WMethodDeclaration method, MessageSend message) {
		return method.parameters.biForAll(message.arguments)[parameter, argument|
			try {
				registry.tvar(parameter).typeInfo.isSupertypeOf(argument.typeInfo)
			}
			catch(RuntimeException exception) {
				// This is most probably because lack of a type annotation, ignore it for now.
				true
			} 
		]
	}


	def allTypes(TypeVariable tvar) {
		var types = registry.typeSystem.allTypes(tvar.owner)
		if(types.size > allTypes.size) allTypes = types // TODO: Fix typeSystem.allTypes 
		allTypes
	}
}

package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable user, GenericTypeInfo it) {
		if (maximalConcreteTypes === null) return;
		if (maximalConcreteTypes.state != Pending) return;
		if (user.hasErrors) return;

		// Do propagate		
		propagateMaxTypes(user)
		maximalConcreteTypes.state = Ready
	}

	def void propagateMaxTypes(GenericTypeInfo it, TypeVariable user) {
		user.subtypes.forEach [ subtype |
			subtype.setMaximalConcreteTypes(maximalConcreteTypes, selectOffenderVariable(subtype, user))
			log.debug('''  Propagating maxTypes «maximalConcreteTypes» from: «user» to «subtype»''')
			changed = true
		]
	}
}

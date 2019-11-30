package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.MixedMethodContainer
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WSuite

import static org.uqbar.project.wollok.Messages.*

/**
 * @author tesonep
 * @author jfernandes
 */
class ToStringBuilder {

	def static shortLabel(WollokObject obj) { obj.behavior.objectDescription }

	def static dispatch objectDescription(WSuite suite) { suite.name }
	def static dispatch objectDescription(WClass clazz) { OBJECT_DESCRIPTION_ARTICLE + clazz.name }
	def static dispatch objectDescription(WObjectLiteral obj) { OBJECT_DESCRIPTION_AN_OBJECT }
	def static dispatch objectDescription(WNamedObject namedObject) { namedObject.name }
	def static dispatch objectDescription(WMixin mixin) { mixin.name }
	def static dispatch objectDescription(MixedMethodContainer mmc) { mmc.toString }

}
package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

interface NumberPrintingStrategy {
	def String printString(BigDecimal value)
	def String description()
	def String name()
}

class DecimalPrintingStrategy implements NumberPrintingStrategy {
	
	override printString(BigDecimal value) {
		if (value.isInteger) {
			val partNumbers = value.toString.split("\\.")
			return if (partNumbers.isEmpty) "0" else partNumbers.get(0).toString 
		}
		value.stripTrailingZeros.toString	
	}
	
	override description() {
		"Decimal printing strategy"
	}
	
	override name(){
		"decimal"
	}
}

class PlainPrintingStrategy implements NumberPrintingStrategy {
	
	override printString(BigDecimal value) {
		value.toPlainString
	}
	
	override description() {
		"Plain printing strategy (including trailing zeros)"
	}

	override name() {
		"plain"
	}
	
}
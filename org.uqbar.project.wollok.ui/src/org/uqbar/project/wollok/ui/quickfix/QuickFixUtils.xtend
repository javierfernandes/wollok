package org.uqbar.project.wollok.ui.quickfix

import org.eclipse.emf.ecore.EObject


import org.eclipse.jface.text.IRegion
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.WollokConstants.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.eclipse.xtend.lib.annotations.Data
import org.uqbar.project.wollok.wollokDsl.Import

/**
 * Provides utilities for quickfixes.
 * For example extension methods for common tasks when directly manipulating
 * the document text, like inserting text already indented.
 * 
 * @author jfernandes
 */
class QuickFixUtils {
	public static val tabChar = "\t"
	public static val blankSpace = " "

	/**
	 * Inserts the given text in a new line after the given EObject.
	 * It will keep the same indentation as the previous line.
	 */
	def static insertAfter(IModificationContext context, EObject e, String textToInsert) {
		val newBlock = (System.lineSeparator + textToInsert).replaceAll(System.lineSeparator,
			e.marginFromPreviousLine(context))
		context.xtextDocument.replace(e.after, 0, newBlock)
	}

	def static insertJustBefore(IModificationContext context, EObject e, String textToInsert) {
		insertBefore(context, e, textToInsert, false)
	}

	def static insertBefore(IModificationContext context, EObject e, String textToInsert) {
		insertBefore(context, e, textToInsert, true)
	}

	def static insertBefore(IModificationContext context, EObject e, String textToInsert, boolean withLineSeparator) {
		var separator = ""
		if (withLineSeparator) separator = System.lineSeparator
		val newBlock = (textToInsert + separator).replaceAll(System.lineSeparator, e.marginFromPreviousLine(context))
		context.xtextDocument.replace(e.before, 0, newBlock)
	}

	def static void delete(IXtextDocument it, EObject e) {
		replace(e.before, e.node.length, "")
	}

	def static void deleteToken(IXtextDocument it, EObject e, String token) {
		var length = token.length
		val trimText = get.substring(e.before, e.after)
		if (trimText.indexOf(token) == -1) return;
		var start = e.before + trimText.indexOf(token)
		var afterToken = start + length
		val hasSpaceAfter = get.substring(afterToken, afterToken + 1).equals(" ")
		if (hasSpaceAfter) {
			length++
		}
		replace(start, length, "")
	}

	def static void replaceWith(IXtextDocument it, EObject what, EObject withWhat) {
		replace(what.before, what.node.length, withWhat.node.text)
	}

	def static void replaceWith(IXtextDocument it, EObject what, String newText) {
		replace(what.before, what.node.length, newText)
	}

	// ****************** AST UTILS *********************
	def static void prepend(IXtextDocument document, EObject beforeObject, String append) {
		document.replace(beforeObject.before, 0, append)
	}

	def static void append(IXtextDocument document, EObject afterObject, String append) {
		document.replace(afterObject.after, 0, append)
	}

	def static before(EObject element) {
		element.node.offset
	}

	def static after(EObject element) {
		element.node.endOffset
	}

	def static node(EObject element) {
		NodeModelUtils.findActualNodeFor(element)
	}

	def static nextSiblingCode(EObject element) {
		element.node?.nextSibling?.text?.trim	
	}
	
	def static previousSiblingCode(EObject element) {
		element.node?.previousSibling?.text?.trim	
	}
	
	def static firstNonEmptyPosition(IXtextDocument document, INode node) {
		var position = node.offset
		while (document.getChar(position++) == ' ') { }
		position - node.offset
	}
	
	def static hasEffectiveNextSibling(EObject o) {
		o.node.hasNextSibling && o.nextSiblingCode.equals(",") && o.effectiveNextSibling !== null
	}
	
	def static effectiveNextSibling(EObject o) {
		o.node.nextSibling?.nextSibling
	}

	def static hasEffectivePreviousSibling(EObject o) {
		o.node.hasPreviousSibling && o.previousSiblingCode.equals(",") && o.effectivePreviousSibling !== null 
	}
	
	def static effectivePreviousSibling(EObject o) {
		o.node.previousSibling?.previousSibling
	}
	
	/**
	 * Common method - compute margin that should by applied to a new method
	 * If method container
	 * - does not exists (such in isolated tests) 
	 * - has no methods nor variable declarations, 
	 * 		placeToAdd should not be considered
	 * Otherwise we use default margin based on line we are calling
	 */
	def static int computeMarginFor(IXtextDocument document, int placeToAdd, WMethodContainer container) {
		if (container === null || container.behaviors.isEmpty) {
			return 1
		}
		val lineInformation = document.getLineInformationOfOffset(placeToAdd)
		var textLine = document.get(lineInformation.offset, lineInformation.length)
		var margin = 0
		while (textLine.startsWith("\t")) {
			margin++
			textLine = textLine.substring(1)
		}
		margin
	}

	def static marginFromPreviousLine(EObject e, IModificationContext context) {
		// finds out the text from the last line System.lineSeparator and the first char of this object
		val previousSibling = e.node.previousSibling
		val lastLine = context.getLineInfo(previousSibling)
		var from = lastLine.endOfLine
		if (from > e.before) {
			from = previousSibling.endOffset
		}
		//var result = context.textBetween(from, e.before)
		//if (!result.contains(System.lineSeparator)) {
		//	result += System.lineSeparator
		//}
		val numberOfTabsMargin = computeMarginFor(context.xtextDocument, e.before, e.declaringContext)
		System.lineSeparator + numberOfTabsMargin.output(tabChar)
	}

	def static getLineInfo(IModificationContext context, INode node) {
		context.xtextDocument.getLineInformationOfOffset(node.offset)
	}

	def static endOfLine(IRegion r) {
		r.offset + r.length
	}

	def static textBetween(IModificationContext context, int startOffset, int endOffset) {
		val length = endOffset - startOffset
		context.xtextDocument.get(startOffset, length)
	}

	def static dispatch grammarDescription(RuleCall it) { "RuleCall " + rule }

	def static dispatch grammarDescription(EObject it) { it }
	
	def static insertImport(WMethodContainer declaringContext, String code, IModificationContext context) {
		val xtextDocument = context.getXtextDocument(declaringContext.fileURI)
		val importLocation = declaringContext.placeToAddImport(xtextDocument)
		xtextDocument.replace(importLocation.placeToAdd, 0, importLocation.formatCode(code))
	}

	def static insertVariable(WMethodContainer declaringContext, String newVarName, IModificationContext context) {
		val lastVariableDefinition = declaringContext.variableDeclarations.sortBy[before]?.last
		if (lastVariableDefinition !== null) {
			context.insertAfter(lastVariableDefinition, VAR + " " + newVarName)
		} else {
			val firstBehavior = declaringContext.behaviors.sortBy[before]?.head
			if (firstBehavior !== null) {
				context.insertBefore(firstBehavior, VAR + " " + newVarName)
			}
		}
	}
	
	def static placeToAddImport(WMethodContainer declaringContext, IXtextDocument xtextDocument) {
		val position = importToAddPosition(declaringContext.allImports)
		val location = importToAddLocation(xtextDocument, position)
		new QuickFixLocation(position, location)
	}
	
	def static int importToAddPosition(Iterable<Import> imports) {
		if(!imports.isEmpty) imports.last.after else 0
	}
	
	def static Location importToAddLocation(IXtextDocument xtextDocument, int position) {
		val IRegion lineInformation = xtextDocument.getLineInformationOfOffset(position)
		val IRegion nextLineInformation = xtextDocument.getLineInformationOfOffset(lineInformation.endOfLine + 2)
		val String lineText = xtextDocument.get(lineInformation.offset, lineInformation.length)
		val String nextLineText = xtextDocument.get(nextLineInformation.offset, nextLineInformation.length)
		var Location result

		if (position.equals(0)) {
			if (!lineText.isEmpty)
				result = Location.TWOLINESBEFORE
			else if(!nextLineText.isEmpty) result = Location.BEFORE else result = Location.NONE
		} else {
			if(!nextLineText.isEmpty) result = Location.ALL else result = Location.AFTER

		}

		result
	}
	
	def static insertMethod(WMethodContainer declaringContext, String code, IModificationContext context) {
		val constructorLocation = declaringContext.placeToAddMethod
		val xtextDocument = context.getXtextDocument(declaringContext.fileURI)
		xtextDocument.replace(constructorLocation.placeToAdd, 0, constructorLocation.formatCode(code))
	}

	def static insertConstructor(WMethodContainer declaringContext, String code, IModificationContext context) {
		val constructorLocation = declaringContext.placeToAddConstructor
		val xtextDocument = context.getXtextDocument(declaringContext.fileURI)
		xtextDocument.replace(constructorLocation.placeToAdd, 0, constructorLocation.formatCode(code))
	}

	def static insertProperty(WMethodContainer declaringContext, String code, IModificationContext context) {
		val variableLocation = declaringContext.placeToAddVariable
		val xtextDocument = context.getXtextDocument(declaringContext.fileURI)
		xtextDocument.replace(variableLocation.placeToAdd, 0, variableLocation.formatCode(code))
	}
	
	def static placeToAddMethod(WMethodContainer declaringContext) {
		val behaviors = declaringContext.behaviors
		if (behaviors.isEmpty) {
			return new QuickFixLocation(declaringContext.defaultPlace, Location.ALL)
		}
		new QuickFixLocation(behaviors.sortBy [ before ].last.after, Location.AFTER)
	}

	def static placeToAddConstructor(WMethodContainer declaringContext) {
		val constructors = declaringContext.constructors().toList
		if (!constructors.isEmpty) {
			return new QuickFixLocation(constructors.sortBy [ before ].last.after, Location.AFTER)
		}
		val behaviors = declaringContext.behaviors
		if (!behaviors.isEmpty) {
			return new QuickFixLocation(behaviors.sortBy [ before ].head.before - 1, Location.BEFORE)
		}
		new QuickFixLocation(declaringContext.defaultPlace, Location.ALL)
	}

	def static placeToAddVariable(WMethodContainer declaringContext) {
		val constructors = declaringContext.constructors().toList
		if (!constructors.isEmpty) {
			return new QuickFixLocation(constructors.sortBy [ before ].head.before, Location.BEFORE)
		}
		val behaviors = declaringContext.behaviors
		if (!behaviors.isEmpty) {
			return new QuickFixLocation(behaviors.sortBy [ before ].head.before - 1, Location.BEFORE)
		}
		val variables = declaringContext.variables.toList
		if (!variables.isEmpty) {
			return new QuickFixLocation(variables.sortBy [ before ].last.after, Location.AFTER)
		}
		new QuickFixLocation(declaringContext.defaultPlace, Location.ALL)
	}
	
	def static int getDefaultPlace(WMethodContainer declaringContext) {
		declaringContext.node.endOffset - 1
	}
	
	def static output(int numberOfChars, String character) {
		if (numberOfChars < 1) return ""
		(1..numberOfChars).map [ character ].reduce [ acum, c | acum + c ]
	}
	
	def static generateNewImportCode(String newObjectName) {
		IMPORT + blankSpace + newObjectName
	}

	def static generateNewWKOCode(String newObjectName) {
		WKO + blankSpace + newObjectName + " {" + System.lineSeparator + System.lineSeparator + "}" + System.lineSeparator + System.lineSeparator
	}
	
	def static generateNewClassCode(String newClassName) {
		CLASS + blankSpace + newClassName + " {" + System.lineSeparator + System.lineSeparator + "}" + System.lineSeparator + System.lineSeparator
	}
	
}

enum Location { BEFORE, AFTER, ALL, TWOLINESBEFORE, NONE }

@Data
class QuickFixLocation {
	
	int placeToAdd
	Location location
	
	def formatCode(String code) {
		if (location === Location.BEFORE)
			code + System.lineSeparator
		else if (location === Location.TWOLINESBEFORE)
			code + System.lineSeparator + System.lineSeparator
		else if (location === Location.AFTER)
			System.lineSeparator + code
		else if (location === Location.NONE)
			code
		else
			System.lineSeparator + code + System.lineSeparator
	}
}
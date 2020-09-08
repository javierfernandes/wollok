package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.TerminalRule
import org.eclipse.xtext.nodemodel.INode

import static extension org.uqbar.project.wollok.ui.console.highlight.WTextExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Moved this logic to its own class.
 * It basically computes styles ranges for highligthing wollok code.
 * Contrary to WollokHighlightingCalculator this works at AST level.
 * 
 * From the console (repl) we tried to use WollokHighlightingCalculator (we are actually using it)
 * but that object just calculates "customs" highlights (like variables / parameters, etc).
 * It doesn't compute the core basic highlights like keywords, or terminals like Strings and numbers.
 * 
 * I didn't find a way to reuse that from the xtext editor, so I had to made part of that again
 * here with my own code.
 * 
 * @author jfernandes
 */
class WollokConsoleHighlighter {
	public static val KEYWORD_COLOR_LIGHT = new Color(null, new RGB(127, 0, 85))
	public static val KEYWORD_COLOR_DARK = new Color(null, new RGB(19, 149, 214))

	val terminalColorsLight = #{
		"STRING" -> newColor(42, 0, 255),
		"INT" -> newColor(125, 125, 125),
		"SL_COMMENT" -> newColor(62, 127, 95),
		"ML_COMMENT" -> newColor(62, 127, 95)
	}

	val terminalColorsDark = #{
		"STRING" -> newColor(23,198,163),
		"INT" -> newColor(104,151,187),
		"SL_COMMENT" -> newColor(62, 127, 95),
		"ML_COMMENT" -> newColor(62, 127, 95)
	}
	
	def terminalColors() {
		if (environmentHasDarkTheme) terminalColorsDark else terminalColorsLight  
	} 
	
	def boolean allSymbols(String value) {
		for (var i = 0; i < value.length; i++) {
			if (Character.isLetterOrDigit(value.charAt(i))) return false
		}
		return true
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, Keyword it, LineStyleEvent event, int headerLength) { 
		if (value.length > 1 && !value.allSymbols) {
			addStyle(event, n, headerLength, styles, "KEYWORD", keywordColor, null, SWT.BOLD)
		}
	}
	
	def static keywordColor() {
		if (environmentHasDarkTheme) KEYWORD_COLOR_DARK else KEYWORD_COLOR_LIGHT
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, RuleCall it, LineStyleEvent event, int headerLength) {
		checkByName(event, n, headerLength, styles, rule.name)
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, TerminalRule it, LineStyleEvent event, int headerLength) {
		checkByName(event, n, headerLength, styles, name)
	}
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, EObject it, LineStyleEvent event, int headerLength) {
	}

	def dispatch processASTNode(List<StyleRange> styles, INode n, Void it, LineStyleEvent event, int headerLength) { }


	// helpers
	
	def addStyle(LineStyleEvent event, INode n, int headerLength, List<StyleRange> styles, String data, Color color) {
		addStyle(event, n, headerLength, styles, data, color, null, SWT.NONE)
	}
	
	def addStyle(LineStyleEvent event, INode n, int headerLength, List<StyleRange> styles, String data, Color fgColor, Color bgColor, int style) {
		val newStyle = new StyleRange(event.lineOffset + n.totalOffset - headerLength, n.length, fgColor, bgColor, style)
		newStyle.data = data
		styles.merge(newStyle)
	}	
	
	def checkByName(LineStyleEvent event, INode n, int headerLength, List<StyleRange> styles, String name) {
		if (terminalColors.containsKey(name)) {
			addStyle(event, n, headerLength, styles, name, terminalColors.get(name))
		}
	}
	
}


package org.uqbar.project.wollok.ui.console.editor.rtf

import java.util.List
import org.eclipse.swt.custom.StyleRange
import org.uqbar.project.wollok.ui.console.editor.WollokStyle

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

class WollokRTFWriter {

	public static String ESCAPE_INIT = "m"

	RTFForegroundColorTagCommand foregroundCommand
	val List<RTFTagCommand> tagCommands
	val WollokStyle style
	WollokRTFColorMatcher wollokRTFColorMatcher

	/**
	 * @params text    The complete text to copy
	 * @params style   A Wollok Style object that contains everything to show them
	 */
	new(WollokStyle _style) {
		style = _style
		wollokRTFColorMatcher = new WollokRTFColorMatcher(style)
		foregroundCommand = new RTFForegroundColorTagCommand(wollokRTFColorMatcher)
		tagCommands = #[foregroundCommand, new RTFBoldCommand, new RTFItalicCommand, new RTFUnderlineCommand, new RTFStrikeoutCommand]
	}

	def String getRTFText() {
		'''
		{\rtf1\ansi\deff0
		{\colortbl;
		''' +
		wollokRTFColorMatcher.colorTable +
		'''
		}
		{\fonttbl {\f0 \fmodern Courier;}}
		\f0
		\b
		\cf1
		''' + linesText + '''
		\b0
		}
		'''
	}

	def String getLinesText() {
		val result = new StringBuffer
		for (i : style.lineStart .. style.lineEnd) {
			processRTFLine(style.getLine(i), style.getStylesAtLine(i), result)
			result.append("\\line")
			result.append(System.getProperty("line.separator"))
		}
		result.toString
	}

	def void processRTFLine(String line, List<StyleRange> styles, StringBuffer result) {
		styles.forEach[style |
			style.apply(line + System.getProperty("line.separator"), result)
		]
	}

	def apply(StyleRange _style, String line, StringBuffer result) {
		result.append("{")
		val tagsApplied = tagCommands.filter[tagCommand|tagCommand.appliesTo(_style)].toList
		tagsApplied.forEach[it.formatTag(_style, result)]
		result.append(" ")
		val end = Math.min(line.length, _style.start + _style.length)
		if (end > 0) {
			try {
				result.append(line.substring(_style.start, end).deleteAnsiCharacters.replaceRTFEscapeCharacters)
			} catch (IndexOutOfBoundsException e) {
				throw new RuntimeException("Error applying RTF style " + _style + " - end " + end + " | out of range for line " + line + " ~ line length " + line.length, e)
			}
		}
		// Deactivate tags appended to a range style
		tagsApplied.forEach[ tag | tag.deactivateTag(_style, result) ]
		result.append("}")
	}
	
	def replaceRTFEscapeCharacters(String text) {
		// 
		val result = new StringBuffer
		val mapEscaped = mapEscapeChars
		for (var int i = 0; i < text.length; i++) {
			val actualChar = text.charAt(i)
			val String replacement = mapEscaped.get("" + actualChar) ?: "" + actualChar
			result.append(replacement)
		} 
		result.toString
	}
	
	def mapEscapeChars() {
		newHashMap => [
			put("{", "\\{")
			put("}", "\\}")
		]
	}
	
}

package org.uqbar.project.wollok.utils

/**
 * 
 * @author jfernandes
 */
class StringUtils {

	def static splitCamelCase(String s) {
		s.replaceAll(
			String.format(
				"%s|%s|%s",
				"(?<=[A-Z])(?=[A-Z][a-z])",
				"(?<=[^A-Z])(?=[A-Z])",
				"(?<=[A-Za-z])(?=[^A-Za-z])"
			),
			" "
		)
	}

	def static firstUpper(String s) {
		Character.toUpperCase(s.charAt(0)) + s.substring(1)
	}

	def static String padRight(String s, int n) {
		return String.format("%1$-" + n + "s", s);
	}

	def static String truncate(String s, int max) {
		if(s.length < max) return s
		s.substring(0, max) + "..."
	}

	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }

	/**
	 * Returns a substring from the begining until the last occurrence of a given character.  
	 */
	static def copyUptoLast(String string, Character character) {
		string.substring(0, string.lastIndexOf(character))
	}
	
	static def safeLength(String value) {
		(value ?: "").length
	}
}
